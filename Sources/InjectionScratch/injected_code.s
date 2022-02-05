//
//  InjectionScratch.h
//  InjectionScratch
//
//  Created by John Holdsworth on 13/01/2022.
//  Copyright © 2022 John Holdsworth. All rights reserved.
//  Repo: https://github.com/johnno1962/InjectionScratch
//

#include <TargetConditionals.h>

.align 14
.global _injected_code
_injected_code:
    #if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
    // This is where recompiled code is loaded into memory.
    // Unfortunately, LLDB does not support giving a better
    // idea of where your injected code has failed. To get
    // a stacktrace, use an `@_exported import HotReloading`
    // in your source file and type `p HotReloading.stack()`.
    .rept 400*16384
    nop
    nop
    nop
    nop
    .endr
    #endif
.global _injected_code_end
_injected_code_end:
    nop
