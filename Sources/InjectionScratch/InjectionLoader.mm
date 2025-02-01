//
//  InjectionLoader.mm
//
//  Created by John Holdsworth on 13/01/2022.
//  Copyright © 2022 John Holdsworth. All rights reserved.
//
//  Repo: https://github.com/johnno1962/InjectionLoaderBuilder
//  $Id: //depot/InjectionScratch/Sources/InjectionScratch/InjectionLoader.mm#6 $
//  See: https://saagarjha.com/blog/2020/02/23/jailed-just-in-time-compilation-on-ios/
//

#import "InjectionLoader.h"

#import <mach-o/dyld.h>
#import <mach-o/loader.h>
#import <mach-o/getsect.h>
#import <mach/vm_param.h>
#import <sys/mman.h>
#import <dlfcn.h>
#import <vector>

#define PAGE_ROUND(_sz) (((_sz) + PAGE_SIZE-1) & ~(PAGE_SIZE-1))

const char *injected_code_version = "$Id: //depot/InjectionScratch/Sources/InjectionScratch/InjectionLoader.mm#6 $";
static NSString *presented;

static void *failed(const char *msg, ...) {
    va_list ap;
    va_start(ap, msg);
    printf("🔥 InjectionLoader: ⚠️ ");
    vprintf(msg, ap);
    va_end(ap);
    return NULL;
}

/// For licensing some day perhaps.
/// @param response license key for developer username.
void presentInjectionLoader(NSString *response) {
    presented = response;
}

/// Perform a pseudo dynamic load of dylib received on a socket into injected_code.
///
/// You can't just malloc a peice of memory and make it executable but you can dlopen
/// a large empty executable and make it writable temporarilly as the debugger needs
/// to be able to write to the text (executable) segment to set breakpoints. Job done.
///
/// Includes other code to perfrom most of what dlopen does but emulating the
/// initialisation of Swift meta-data structures is not quite possible on a device.
/// Pointers in memory to external symbols can not be bound without brining in a
/// mass of code from the dynamic linker. Function pointers are bound using a
/// the slightly modified version of "fishhook" in the SwiftTrace package.
///
/// @param scratch Current pointer to free potentially executable memory.
/// @param length length of dyanmic library to pseudo load.
/// @param from SimpleSocket with connection to InjectionIII app.
/// @param used Return % of injected_code memory used.
/// @returns pointer to injected_code to load next image.
///
void * _Nullable loadPseudoImage(void * _Nullable scratch, int32_t length,
                                 id<InjectionReader> _Nonnull from, double *used) {
    /// Large empty area of nops for reading in images.
    char *injected_code = (char *)dlsym(RTLD_DEFAULT, "injected_code");
    char *injected_code_end = (char *)dlsym(RTLD_DEFAULT, "injected_code_end");

    static void *last_scratch;
    if (!scratch)
        return injected_code_end - injected_code < PAGE_SIZE ?
                nullptr : last_scratch = injected_code;
    if (scratch != last_scratch)
        return failed("Scratch pointer sync error.\n");

    size_t image_pages = PAGE_ROUND(length);
    char *image_end = (char *)scratch + image_pages;
    if (used)
        *used = 100.00 * (image_end - injected_code) /
            (injected_code_end - injected_code);

    if (image_end > injected_code_end)
        return failed("Insufficient buffer space available.\n");

    // make executable pages from scratch image writable
    if (mprotect(scratch, image_pages, PROT_WRITE|PROT_READ) != KERN_SUCCESS)
        return failed("Unable to make pages writable %s\n",
                      strerror(errno));

    // read image into injected_code
    if (![from readBytes:scratch length:length
                     cmd:sel_registerName("loadPseudoImage")])
        return failed("Unable to read %d bytes: %s\n",
                      length, strerror(errno));

    auto *header = (struct mach_header_64 *)scratch;

    // replace selector names with their registered values
    uint64_t typeref_size = 0;
    if (char *typeref_start = getsectdatafromheader_64(header,
                  SEG_DATA, "__objc_selrefs", &typeref_size))
        for (SEL *s2 = (SEL *)typeref_start;
             (char *)s2 < typeref_start+typeref_size; s2++)
            *s2 = sel_registerName(*(char **)s2);

    // Populate "isa" of NSString constants
    if (char *typeref_start = getsectdatafromheader_64(header,
                  SEG_DATA, "__cfstring", &typeref_size)) {
        void *cfstr = dlsym(RTLD_DEFAULT, "__CFConstantStringClassReference");

        struct cfstring {
            void *isa;
            int nnt, space;
            char *str;
            size_t len;
        };

        if (!cfstr)
            failed("No __cfstring? %p", cfstr);
        else
            for (struct cfstring *s2 = (struct cfstring *)typeref_start;
                 (char *)s2 < typeref_start+typeref_size; s2++)
                s2->isa = cfstr;
    }

    // find size of executable segment
    struct load_command *cmd =
        (struct load_command *)((intptr_t)header + sizeof(struct mach_header_64));
    struct segment_command_64 *seg_text = 0;
    for (uint32_t i = 0; i < header->ncmds; i++,
         cmd = (struct load_command *)((intptr_t)cmd + cmd->cmdsize)) {
        switch(cmd->cmd) {
            case LC_SEGMENT:
            case LC_SEGMENT_64:
                if (!strcmp(((struct segment_command_64 *)cmd)->segname, SEG_TEXT))
                    seg_text = (struct segment_command_64 *)cmd;
        }
    }

    if (!seg_text)
        return failed("No seg_text?");

    // make executable segment executable again
    if (mprotect(scratch, PAGE_ROUND(seg_text->vmsize),
                 PROT_READ|PROT_EXEC) != KERN_SUCCESS)
        return failed("Unable to make text executable %s\n",
                      strerror(errno));

    typedef int (*Rebinder)(void * _Nonnull header,
                            intptr_t slide,
                            struct rebinding rebindings[],
                            size_t rebindings_nel);

    static Rebinder rebind_symbols_image;
    if (!rebind_symbols_image)
        if (NSString *swiftTrace = [[NSBundle mainBundle].privateFrameworksPath
            stringByAppendingPathComponent:@"SwiftTraceD.framework/SwiftTraceD"])
            if (void *handle = dlopen(swiftTrace.UTF8String, RTLD_NOLOAD))
                rebind_symbols_image = (Rebinder)dlsym(handle, "rebind_symbols_image");

    if (!rebind_symbols_image)
        failed("No SwiftTrace?");
    else
        (*rebind_symbols_image)(header, 0, nullptr, -1);

    // record pseudo image and bump pointer
    return last_scratch = image_end;
}
