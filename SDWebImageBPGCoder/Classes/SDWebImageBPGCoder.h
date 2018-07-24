//
//  SDWebImageBPGCoder.h
//  SDWebImage-BPGCoder
//
//  Created by DreamPiggy on 2017/10/26.
//

#import <SDWebImage/SDWebImage.h>

static const SDImageFormat SDImageFormatBPG = 11;

@interface SDWebImageBPGCoder : NSObject <SDImageCoder>

@property (nonatomic, class, readonly, nonnull) SDWebImageBPGCoder *sharedCoder;

@end
