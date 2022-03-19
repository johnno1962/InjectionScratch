//
//  InjectionScratch.m
//  
//  Created by John Holdsworth on 28/01/2022.
//  Copyright © 2022 John Holdsworth. All rights reserved.
//  Repo: https://github.com/johnno1962/InjectionScratch
//
//  $Id: //depot/InjectionScratch/Sources/InjectionScratch/InjectionScratch.m#1 $
//

#import "include/InjectionScratch.h"

//@import InjectionLoader;
extern void presentInjectionLoader(NSString * _Nonnull response);
extern void * _Nullable loadPseudoImage(void * _Nullable scratch, int32_t length,
                id<InjectionReader> _Nonnull from, double * _Nullable used);

// Passthough required to make symbols in embedded binary framework available.

void presentInjectionScratch(NSString * _Nonnull response) {
    presentInjectionLoader(response);
}
void * _Nullable loadScratchImage(void * _Nullable scratch, int32_t length,
    id<InjectionReader> _Nonnull from, double * _Nullable used) {
    return loadPseudoImage(scratch, length, from, used);
}
