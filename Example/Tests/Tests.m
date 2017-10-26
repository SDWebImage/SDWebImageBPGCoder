//
//  SDWebImageBPGCoderTests.m
//  SDWebImageBPGCoderTests
//
//  Created by dreampiggy on 10/26/2017.
//  Copyright (c) 2017 dreampiggy. All rights reserved.
//

// https://github.com/Specta/Specta
#import <Specta/Specta.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImageCodersManager.h>
#import <SDWebImageBPGCoder/SDWebImageBPGCoder.h>

SpecBegin(InitialSpecs)

describe(@"BPG Test", ^{
    beforeAll(^{
        SDWebImageBPGCoder *BPGCoder = [SDWebImageBPGCoder sharedCoder];
        [[SDWebImageCodersManager sharedInstance] addCoder:BPGCoder];
    });
    
    beforeEach(^{
        [[SDWebImageManager sharedManager] cancelAll];
    });
    
    it(@"Static BPG Works", ^{
        NSURL *staticBPGURL = [NSURL URLWithString:@"https://bellard.org/bpg/003.bpg"];
        UIImageView *imageView = [UIImageView new];
        waitUntil(^(DoneCallback done) {
            [imageView sd_setImageWithURL:staticBPGURL completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                expect(image).toNot.beNil();
                expect(image.images).to.beNil();
                done();
            }];
        });
    });
    
    it(@"Animated BPG Works", ^{
        NSURL *animatedBPGURL = [NSURL URLWithString:@"https://bellard.org/bpg/cinemagraph-6.bpg"];
        UIImageView *imageView = [UIImageView new];
        waitUntil(^(DoneCallback done) {
            [imageView sd_setImageWithURL:animatedBPGURL completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                expect(image).toNot.beNil();
                expect(image.images).toNot.beNil();
                expect(image.images.count).to.beGreaterThan(0);
                done();
            }];
        });
    });
});

SpecEnd

