//
//  SDWebImageBPGCoder.m
//  SDWebImage-BPGCoder
//
//  Created by DreamPiggy on 2017/10/26.
//

#import "SDWebImageBPGCoder.h"
#if __has_include(<HCImage_BPG/HCImage+BPG.h>)
#import <HCImage_BPG/HCImage+BPG.h>
#else
#import "HCImage+BPG.h"
#endif

#define SD_FOUR_CC(c1,c2,c3,c4) ((uint32_t)(((c4) << 24) | ((c3) << 16) | ((c2) << 8) | (c1)))

@implementation SDWebImageBPGCoder

+ (instancetype)sharedCoder
{
    static SDWebImageBPGCoder *coder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coder = [[SDWebImageBPGCoder alloc] init];
    });
    return coder;
}

#pragma mark - Decode
- (BOOL)canDecodeFromData:(NSData *)data
{
    return [[self class] isBPGFormatForData:data];
}

- (UIImage *)decodedImageWithData:(NSData *)data
{
    if (!data) {
        return nil;
    }
    HCImage *image = [HCImage imageWithBPGData:data];
    return image;
}

- (UIImage *)decompressedImageWithImage:(UIImage *)image data:(NSData *__autoreleasing  _Nullable *)data options:(NSDictionary<NSString *,NSObject *> *)optionsDict
{
    return image;
}

#pragma mark - Progressive Decode
- (BOOL)canIncrementallyDecodeFromData:(nullable NSData *)data
{
    return [[self class] isBPGFormatForData:data];
}

- (UIImage *)incrementallyDecodedImageWithData:(NSData *)data finished:(BOOL)finished
{
    return [self decodedImageWithData:data];
}

#pragma mark - Encode
- (BOOL)canEncodeToFormat:(SDImageFormat)format
{
    return NO;
}

- (NSData *)encodedDataWithImage:(UIImage *)image format:(SDImageFormat)format
{
    return nil;
}

#pragma mark - Helper
+ (BOOL)isBPGFormatForData:(NSData *)data
{
    if (!data) {
        return NO;
    }
    uint32_t magic4;
    [data getBytes:&magic4 length:4]; // 4 Bytes Magic Code for most file format.
    switch (magic4) {
        case SD_FOUR_CC('B', 'P', 'G', 0xFB): { // BPG
            return YES;
        }
        default: {
            return NO;
        }
    }
}

@end
