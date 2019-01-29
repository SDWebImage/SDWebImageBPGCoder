#ifdef __OBJC__
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import <SDWebImageBPGCoder/SDImageBPGCoder.h>
#import <SDWebImageBPGCoder/libbpg.h>
#if defined(USE_X265)
#import <SDWebImageBPGCoder/bpgenc.h>
#endif

FOUNDATION_EXPORT double SDWebImageBPGCoderVersionNumber;
FOUNDATION_EXPORT const unsigned char SDWebImageBPGCoderVersionString[];

