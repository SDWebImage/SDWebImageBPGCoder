//
//  SDImageBPGCoder.m
//  SDWebImageBPGCoder
//
//  Created by DreamPiggy on 2017/10/26.
//

#import "SDImageBPGCoder.h"
#import "libbpg.h"

#define SD_FOUR_CC(c1,c2,c3,c4) ((uint32_t)(((c4) << 24) | ((c3) << 16) | ((c2) << 8) | (c1)))

static void FreeImageData(void *info, const void *data, size_t size) {
    free((void *)data);
}

@implementation SDImageBPGCoder

+ (instancetype)sharedCoder {
    static SDImageBPGCoder *coder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coder = [[SDImageBPGCoder alloc] init];
    });
    return coder;
}

#pragma mark - Decode
- (BOOL)canDecodeFromData:(NSData *)data {
    return [[self class] isBPGFormatForData:data];
}

- (UIImage *)decodedImageWithData:(NSData *)data options:(SDImageCoderOptions *)options {
    if (!data) {
        return nil;
    }
    BPGDecoderContext *context = bpg_decoder_open();
    if (!context) {
        return nil;
    }
    
    // Only check information, don't decode first frame
    BPGImageInfo info;
    int result = bpg_decoder_get_info_from_buf(&info, NULL, data.bytes, (int)data.length);
    bpg_decoder_close(context);
    if (result < 0) {
        return nil;
    }
    
    BOOL hasAnimation = info.has_animation;
    BOOL decodeFirstFrame = [[options valueForKey:SDImageCoderDecodeFirstFrameOnly] boolValue];
    CGFloat scale = 1;
    if ([options valueForKey:SDImageCoderDecodeScaleFactor]) {
        scale = [[options valueForKey:SDImageCoderDecodeScaleFactor] doubleValue];
        if (scale < 1) {
            scale = 1;
        }
    }
    if (!hasAnimation || decodeFirstFrame) {
        CGImageRef imageRef = [self sd_createBPGImageWithData:data];
        if (!imageRef) {
            return nil;
        }
#if SD_UIKIT || SD_WATCH
        UIImage *staticImage = [[UIImage alloc] initWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
#else
        UIImage *staticImage = [[UIImage alloc] initWithCGImage:imageRef scale:scale orientation:kCGImagePropertyOrientationUp];
#endif
        staticImage.sd_imageFormat = SDImageFormatBPG;
        CGImageRelease(imageRef);
        return staticImage;
    }
    
    // Create new context for animation decode
    context = bpg_decoder_open();
    if (!context) {
        return nil;
    }
    result = bpg_decoder_decode(context, data.bytes, (int)data.length);
    if (result < 0) {
        bpg_decoder_close(context);
        return nil;
    }
    
    BOOL hasAlpha = info.has_alpha;
    int loopCount = info.loop_count;
    BPGDecoderOutputFormat format = hasAlpha ? BPG_OUTPUT_FORMAT_RGBA32 : BPG_OUTPUT_FORMAT_RGB24;
    // Check first frame
    result = bpg_decoder_start(context, format);
    if (result < 0) {
        bpg_decoder_close(context);
        return nil;
    }
    
    NSMutableArray<SDImageFrame *> *frames = [NSMutableArray array];
    
    do {
        @autoreleasepool {
            CGImageRef imageRef = [self sd_createBPGImageWithContext:context];
            if (!imageRef) {
                continue;
            }
    #if SD_UIKIT || SD_WATCH
            UIImage *image = [[UIImage alloc] initWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
    #else
            UIImage *image = [[UIImage alloc] initWithCGImage:imageRef scale:scale orientation:kCGImagePropertyOrientationUp];
    #endif
            CGImageRelease(imageRef);
            
            NSTimeInterval duration = [self sd_frameDurationWithContext:context];
            SDImageFrame *frame = [SDImageFrame frameWithImage:image duration:duration];
            [frames addObject:frame];
        }
    } while (bpg_decoder_start(context, format) >= 0);
    
    bpg_decoder_close(context);
    
    UIImage *animatedImage = [SDImageCoderHelper animatedImageWithFrames:frames];
    animatedImage.sd_imageLoopCount = loopCount;
    animatedImage.sd_imageFormat = SDImageFormatBPG;
    
    return animatedImage;
}

#pragma mark - Encode
- (BOOL)canEncodeToFormat:(SDImageFormat)format {
    return NO;
}

- (NSData *)encodedDataWithImage:(UIImage *)image format:(SDImageFormat)format options:(SDImageCoderOptions *)options {
    return nil;
}

// libbpg currently does not fully support progressive decoding (alpha-only and contains issue), this does not be compatible with `SDProgressiveImageCoder` protocol

// libbpg currently does not contains API to get total frame count, decode specify frame, this does not compatible with `SDAnimatedImageCoder` protocol

#pragma mark - Helper

- (NSTimeInterval)sd_frameDurationWithContext:(nonnull BPGDecoderContext *)context {
    int num, den;
    bpg_decoder_get_frame_duration(context, &num, &den);
    NSTimeInterval frameDuration = (NSTimeInterval)num / den;
    
    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082>
    // for more information.
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    return frameDuration;
}

- (nullable CGImageRef)sd_createBPGImageWithData:(nonnull NSData *)data CF_RETURNS_RETAINED {
    BPGDecoderContext *context = bpg_decoder_open();
    if (!context) {
        return NULL;
    }
    
    int result = 0;
    // Check data valid
    result = bpg_decoder_decode(context, data.bytes, (int)data.length);
    if (result < 0) {
        bpg_decoder_close(context);
        return NULL;
    }
    
    // Check image info
    BPGImageInfo info;
    result = bpg_decoder_get_info(context, &info);
    if (result < 0) {
        bpg_decoder_close(context);
        return NULL;
    }
    
    BOOL hasAlpha = info.has_alpha;
    BPGDecoderOutputFormat format = hasAlpha ? BPG_OUTPUT_FORMAT_RGBA32 : BPG_OUTPUT_FORMAT_RGB24;
    
    // Begin decode (first frame)
    result = bpg_decoder_start(context, format);
    if (result < 0) {
        bpg_decoder_close(context);
        return NULL;
    }
    
    CGImageRef imageRef = [self sd_createBPGImageWithContext:context];
    bpg_decoder_close(context);
    
    return imageRef;
}

- (nullable CGImageRef)sd_createBPGImageWithContext:(nonnull BPGDecoderContext *)context CF_RETURNS_RETAINED {
    // Check image info
    BPGImageInfo info;
    int result = bpg_decoder_get_info(context, &info);
    if (result < 0) {
        return NULL;
    }
    
    BOOL hasAlpha = info.has_alpha;
    size_t width = info.width;
    size_t height = info.height;
    size_t bitsPerPixel = hasAlpha ? 32 : 24;
    size_t bytesPerRow = width * bitsPerPixel / 8;
    size_t rgbaSize = height * bytesPerRow;
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Big;
    bitmapInfo |= hasAlpha ? kCGImageAlphaLast : kCGImageAlphaNone;
    
    uint8_t *rgba = malloc(rgbaSize);
    if (!rgba) {
        return NULL;
    }
    
    // Decode buffer
    for (int y = 0; y < height; y++) {
        // Decode each line
        result = bpg_decoder_get_line(context, rgba + bytesPerRow * y);
        if (result < 0) {
            return NULL;
        }
    }
    
    // Construct a UIImage from the decoded RGBA value array
    CGDataProviderRef provider =
    CGDataProviderCreateWithData(NULL, rgba, rgbaSize, FreeImageData);
    size_t bitsPerComponent = 8;
    CGColorSpaceRef colorSpaceRef = [SDImageCoderHelper colorSpaceGetDeviceRGB];
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    CGDataProviderRelease(provider);
    
    return imageRef;
}

+ (BOOL)isBPGFormatForData:(NSData *)data {
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
