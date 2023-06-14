//
//  SDImageBPGCoder.m
//  SDWebImageBPGCoder
//
//  Created by DreamPiggy on 2017/10/26.
//

#import "SDImageBPGCoder.h"
#if __has_include(<libbpg/libbpg.h>)
#import <libbpg/libbpg.h>
#else
#import "libbpg.h"
#endif

#if defined(USE_X265)
#import "bpgenc.h"
#import <Accelerate/Accelerate.h>
#endif

#define SD_FOUR_CC(c1,c2,c3,c4) ((uint32_t)(((c4) << 24) | ((c3) << 16) | ((c2) << 8) | (c1)))

static void FreeImageData(void *info, const void *data, size_t size) {
    free((void *)data);
}

#if defined(USE_X265)
static int WriteImageData(void *opaque, const uint8_t *buf, int buf_len) {
    NSMutableData *imageData = (__bridge NSMutableData *)opaque;
    NSCParameterAssert(imageData);
    NSCParameterAssert(buf);
    
    [imageData appendBytes:buf length:buf_len];
    return buf_len;
}

static void FillRGBABufferWithBPGImage(vImage_Buffer *red, vImage_Buffer *green, vImage_Buffer *blue, vImage_Buffer *alpha, BPGImage *img) {
    // libbpg RGB color format order is GBR/GBRA
    red->width = img->w;
    red->height = img->h;
    red->data = img->data[2];
    red->rowBytes = img->linesize[2];
    
    green->width = img->w;
    green->height = img->h;
    green->data = img->data[0];
    green->rowBytes = img->linesize[0];
    
    blue->width = img->w;
    blue->height = img->h;
    blue->data = img->data[1];
    blue->rowBytes = img->linesize[1];
    
    if (img->has_alpha) {
        alpha->width = img->w;
        alpha->height = img->h;
        alpha->data = img->data[3];
        alpha->rowBytes = img->linesize[3];
    }
}
#endif

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
    uint32_t width = info.width;
    uint32_t height = info.height;
    
    BOOL hasAnimation = info.has_animation;
    BOOL decodeFirstFrame = [[options valueForKey:SDImageCoderDecodeFirstFrameOnly] boolValue];
    CGFloat scale = 1;
    NSNumber *scaleFactor = options[SDImageCoderDecodeScaleFactor];
    if (scaleFactor != nil) {
        scale = [scaleFactor doubleValue];
        if (scale < 1) {
            scale = 1;
        }
    }
    CGSize thumbnailSize = CGSizeZero;
    NSValue *thumbnailSizeValue = options[SDImageCoderDecodeThumbnailPixelSize];
    if (thumbnailSizeValue != nil) {
#if SD_MAC
        thumbnailSize = thumbnailSizeValue.sizeValue;
#else
        thumbnailSize = thumbnailSizeValue.CGSizeValue;
#endif
    }
    BOOL preserveAspectRatio = YES;
    NSNumber *preserveAspectRatioValue = options[SDImageCoderDecodePreserveAspectRatio];
    if (preserveAspectRatioValue != nil) {
        preserveAspectRatio = preserveAspectRatioValue.boolValue;
    }
    CGSize scaledSize = [SDImageCoderHelper scaledSizeWithImageSize:CGSizeMake(width, height) scaleSize:thumbnailSize preserveAspectRatio:preserveAspectRatio shouldScaleUp:NO];
    if (!hasAnimation || decodeFirstFrame) {
        CGImageRef originImageRef = [self sd_createBPGImageWithData:data];
        if (!originImageRef) {
            return nil;
        }
        // TODO: optimization using vImageScale directly during transform
        CGImageRef imageRef = [SDImageCoderHelper CGImageCreateScaled:originImageRef size:scaledSize];
        CGImageRelease(originImageRef);
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
    if (format == SDImageFormatBPG) {
#if defined(USE_X265)
        return YES;
#else
        return NO;
#endif
    }
    return NO;
}

- (NSData *)encodedDataWithImage:(UIImage *)image format:(SDImageFormat)format options:(SDImageCoderOptions *)options {
#if defined(USE_X265)
    double compressionQuality = 1;
    if (options[SDImageCoderEncodeCompressionQuality]) {
        compressionQuality = [options[SDImageCoderEncodeCompressionQuality] doubleValue];
    }
    BOOL encodeFirstFrame = [options[SDImageCoderEncodeFirstFrameOnly] boolValue];
    
    return [self sd_encodedBPGDataWithImage:image quality:compressionQuality encodeFirstFrame:encodeFirstFrame];
#else
    return nil;
#endif
}

#if defined(USE_X265)
- (nullable NSData *)sd_encodedBPGDataWithImage:(nonnull UIImage *)image quality:(double)quality encodeFirstFrame:(BOOL)encodeFirstFrame {
    BPGEncoderContext *enc_ctx;
    BPGEncoderParameters *p;
    p = bpg_encoder_param_alloc();
    if (!p) {
        return nil;
    }
    // BPG quality is from [0-51], 0 means the best quality but the biggest size. But we define 1.0 the best qualiy, 0.0 the smallest size.
    p->qp = (1 - quality) * 51;
    
    NSArray<SDImageFrame *> *frames = [SDImageCoderHelper framesFromAnimatedImage:image];
    NSMutableData *mutableData = [NSMutableData data];
    
    if (encodeFirstFrame || frames.count == 0) {
        // for static BPG image
        enc_ctx = bpg_encoder_open(p);
        if (!enc_ctx) {
            bpg_encoder_param_free(p);
            return nil;
        }
        
        BPGImage *img = [self sd_encodedBPGFrameWithImage:image];
        if (!img) {
            bpg_encoder_close(enc_ctx);
            bpg_encoder_param_free(p);
            return nil;
        }
        bpg_encoder_encode(enc_ctx, img, WriteImageData, (__bridge void *)mutableData);
        bpg_image_free(img);
    } else {
        // for aniated BPG image
        p->animated = 1;
        
        enc_ctx = bpg_encoder_open(p);
        if (!enc_ctx) {
            bpg_encoder_param_free(p);
            return nil;
        }
        
        for (size_t i = 0; i < frames.count; i++) {
            @autoreleasepool {
                SDImageFrame *currentFrame = frames[i];
                
                BPGImage *img = [self sd_encodedBPGFrameWithImage:currentFrame.image];
                if (!img) {
                    bpg_encoder_close(enc_ctx);
                    bpg_encoder_param_free(p);
                    return nil;
                }
                // libbpg calculate the frame duration like this: seconds = frame_delay_num / frame_delay_den * frame_ticks
                int frame_ticks = currentFrame.duration * p->frame_delay_den / p->frame_delay_num;
                bpg_encoder_set_frame_duration(enc_ctx, frame_ticks);
                bpg_encoder_encode(enc_ctx, img, WriteImageData, (__bridge void *)mutableData);
                bpg_image_free(img);
            }
        }
        // When encoding animations, img = NULL indicates the end of the stream
        bpg_encoder_encode(enc_ctx, NULL, WriteImageData, (__bridge void *)mutableData);
    }
    
    bpg_encoder_close(enc_ctx);
    bpg_encoder_param_free(p);
    
    
    return [mutableData copy];
}


- (BPGImage *)sd_encodedBPGFrameWithImage:(nonnull UIImage *)image {
    CGImageRef imageRef = image.CGImage;
    if (!imageRef) {
        return nil;
    }
    
    BPGImageFormatEnum format = BPG_FORMAT_444;
    BPGColorSpaceEnum color_space = BPG_CS_RGB;
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGImageAlphaInfo alphaInfo = bitmapInfo & kCGBitmapAlphaInfoMask;
    CGBitmapInfo byteOrderInfo = bitmapInfo & kCGBitmapByteOrderMask;
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    BOOL byteOrderNormal = NO;
    switch (byteOrderInfo) {
        case kCGBitmapByteOrderDefault: {
            byteOrderNormal = YES;
        } break;
        case kCGBitmapByteOrder32Little: {
        } break;
        case kCGBitmapByteOrder32Big: {
            byteOrderNormal = YES;
        } break;
        default: break;
    }
    
    // libbpg supports 4 Planr16 channel for RGBA (BPGImage->data[4], which actually store uint16_t not uint8_t)
    // Actually, we can optimize to use RGB888 and convert into Planr16. However, since vImage is fast on GPU, use the built-in method (vImageConvert_RGB16UtoPlanar16U) can boost encoding time.
    vImageConverterRef convertor = NULL;
    vImage_Error v_error = kvImageNoError;
    
    vImage_CGImageFormat srcFormat = {
        .bitsPerComponent = (uint32_t)bitsPerComponent,
        .bitsPerPixel = (uint32_t)bitsPerPixel,
        .colorSpace = CGImageGetColorSpace(imageRef),
        .bitmapInfo = bitmapInfo,
        .renderingIntent = CGImageGetRenderingIntent(imageRef)
    };
    vImage_CGImageFormat destFormat = {
        .bitsPerComponent = 16,
        .bitsPerPixel = hasAlpha ? 64 : 48,
        .colorSpace = [SDImageCoderHelper colorSpaceGetDeviceRGB],
        .bitmapInfo = hasAlpha ? kCGImageAlphaFirst | kCGBitmapByteOrderDefault : kCGImageAlphaNone | kCGBitmapByteOrderDefault // RGB16U/ARGB16U (Non-premultiplied to works for libbpg)
    };
    
    convertor = vImageConverter_CreateWithCGImageFormat(&srcFormat, &destFormat, NULL, kvImageNoFlags, &v_error);
    if (v_error != kvImageNoError) {
        return nil;
    }
    
    vImage_Buffer src;
    v_error = vImageBuffer_InitWithCGImage(&src, &srcFormat, NULL, imageRef, kvImageNoFlags);
    if (v_error != kvImageNoError) {
        return nil;
    }
    vImage_Buffer dest;
    vImageBuffer_Init(&dest, height, width, hasAlpha ? 64 : 48, kvImageNoFlags);
    if (!dest.data) {
        free(src.data);
        return nil;
    }
    
    // Convert input color mode to RGB16U/ARGB16U
    v_error = vImageConvert_AnyToAny(convertor, &src, &dest, NULL, kvImageNoFlags);
    free(src.data);
    vImageConverter_Release(convertor);
    if (v_error != kvImageNoError) {
        free(dest.data);
        return nil;
    }
    
    BPGImage *img = bpg_image_alloc((int)width, (int)height, format, hasAlpha, color_space, (int)bitsPerComponent);
    
    vImage_Buffer red, green, blue, alpha;
    FillRGBABufferWithBPGImage(&red, &green, &blue, &alpha, img);
    
    if (hasAlpha) {
        v_error = vImageConvert_ARGB16UtoPlanar16U(&dest, &alpha, &red, &green, &blue, kvImageNoFlags);
    } else {
        v_error = vImageConvert_RGB16UtoPlanar16U(&dest, &red, &green, &blue, kvImageNoFlags);
    }
    free(dest.data);
    if (v_error != kvImageNoError) {
        return nil;
    }
    
    return img;
}
#endif

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
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
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
