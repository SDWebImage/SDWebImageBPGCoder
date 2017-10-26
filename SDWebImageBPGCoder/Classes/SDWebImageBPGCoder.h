//
//  SDWebImageBPGCoder.h
//  SDWebImage-BPGCoder
//
//  Created by DreamPiggy on 2017/10/26.
//

#import <Foundation/Foundation.h>
#import <SDWebImage/SDWebImageCoder.h>

@interface SDWebImageBPGCoder : NSObject <SDWebImageProgressiveCoder>

+ (nonnull instancetype)sharedCoder;

@end
