//
//  InjectionScratch.h
//  InjectionScratch
//
//  Created by John Holdsworth on 13/01/2022.
//  Copyright © 2022 John Holdsworth. All rights reserved.
//  Repo: https://github.com/johnno1962/InjectionScratch
//
//  $Id: //depot/InjectionScratch/Sources/InjectionScratch/include/InjectionScratch.h#1 $
//

#import <Foundation/Foundation.h>

//! Project version number for InjectionScratch.
FOUNDATION_EXPORT double InjectionLoaderVersionNumber;

//! Project version string for InjectionScratch.
FOUNDATION_EXPORT const unsigned char InjectionLoaderVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <InjectionScratch/PublicHeader.h>

@protocol InjectionReader <NSObject>
- (BOOL)readBytes:(void * _Nonnull)buffer length:(size_t)length cmd:(SEL _Nonnull)cmd;
@end

#ifdef __cplusplus
extern "C" {
#endif
    void presentInjectionScratch(NSString * _Nonnull response);
    void * _Nullable loadScratchImage(void * _Nullable scratch, int32_t length,
                    id<InjectionReader> _Nonnull from, double * _Nullable used);
#ifdef __cplusplus
}
#endif


