//
//  SDImageBPGCoder.h
//  SDWebImageBPGCoder
//
//  Created by DreamPiggy on 2017/10/26.
//

#import <SDWebImage/SDWebImage.h>

static const SDImageFormat SDImageFormatBPG = 11;

@interface SDImageBPGCoder : NSObject <SDImageCoder>

@property (nonatomic, class, readonly, nonnull) SDImageBPGCoder *sharedCoder;

@end
