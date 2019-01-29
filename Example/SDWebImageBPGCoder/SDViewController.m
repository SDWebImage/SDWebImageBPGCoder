//
//  SDViewController.m
//  SDWebImageBPGCoder
//
//  Created by dreampiggy on 10/26/2017.
//  Copyright (c) 2017 dreampiggy. All rights reserved.
//

#import "SDViewController.h"
#import <SDWebImage/SDWebImage.h>
#import <SDWebImageBPGCoder/SDWebImageBPGCoder.h>

@interface SDViewController ()

@end

@implementation SDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SDImageBPGCoder *BPGCoder = [SDImageBPGCoder sharedCoder];
    [[SDImageCodersManager sharedManager] addCoder:BPGCoder];
    NSURL *staticBPGURL = [NSURL URLWithString:@"https://bellard.org/bpg/003.bpg"];
    NSURL *animatedBPGURL = [NSURL URLWithString:@"https://bellard.org/bpg/cinemagraph-6.bpg"];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height / 2)];
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, screenSize.height / 2, screenSize.width, screenSize.height / 2)];
    
    [self.view addSubview:imageView1];
    [self.view addSubview:imageView2];
    
    [imageView1 sd_setImageWithURL:staticBPGURL completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image) {
            NSLog(@"Static BPG load success");
        }
    }];
    [imageView2 sd_setImageWithURL:animatedBPGURL completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image.images) {
            NSLog(@"Animated BPG load success");
        }
    }];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
