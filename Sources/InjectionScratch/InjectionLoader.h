//
//  InjectionLoader.h
//  InjectionLoader
//
//  Created by John Holdsworth on 13/01/2022.
//  Copyright © 2022 John Holdsworth. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for InjectionLoader.
FOUNDATION_EXPORT double InjectionLoaderVersionNumber;

//! Project version string for InjectionLoader.
FOUNDATION_EXPORT const unsigned char InjectionLoaderVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <InjectionLoader/PublicHeader.h>

@protocol InjectionReader <NSObject>
- (BOOL)readBytes:(void * _Nonnull)buffer length:(size_t)length cmd:(SEL _Nonnull)cmd;
@end

#ifdef __cplusplus
extern "C" {
#endif
    void presentInjectionLoader(NSString * _Nonnull response);
    void * _Nullable loadPseudoImage(void * _Nullable scratch, int32_t length,
                    id<InjectionReader> _Nonnull from, double * _Nullable used);
#ifdef __cplusplus
}
#endif


