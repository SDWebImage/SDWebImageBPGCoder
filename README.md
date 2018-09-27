# SDWebImageBPGCoder

[![CI Status](http://img.shields.io/travis/SDWebImage/SDWebImageBPGCoder.svg?style=flat)](https://travis-ci.org/SDWebImage/SDWebImageBPGCoder)
[![Version](https://img.shields.io/cocoapods/v/SDWebImageBPGCoder.svg?style=flat)](http://cocoapods.org/pods/SDWebImageBPGCoder)
[![License](https://img.shields.io/cocoapods/l/SDWebImageBPGCoder.svg?style=flat)](http://cocoapods.org/pods/SDWebImageBPGCoder)
[![Platform](https://img.shields.io/cocoapods/p/SDWebImageBPGCoder.svg?style=flat)](http://cocoapods.org/pods/SDWebImageBPGCoder)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

This is a demo to show to build custom decoder for SDWebImage by embedding third-party framework.

## Requirements

+ iOS 8
+ macOS 10.10

## Installation

SDWebImageBPGCoder is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SDWebImageBPGCoder'
```

## Usage

To use BPG coder, you should firstly add the `SDWebImageBPGCoder` to the coders manager. Then you can call the View Category method to start load BPG images.

+ Objective-C

```objective-c
SDImageBPGCoder *BPGCoder = [SDImageBPGCoder sharedCoder];
[[SDImageCodersManager sharedManager] addCoder:BPGCoder];
UIImageView *imageView;
[imageView sd_setImageWithURL:url];
```

+ Swift

```swift
let BPGCoder = SDImageBPGCoder.shared
SDImageCodersManager.shared.addCoder(BPGCoder)
let imageView: UIImageView
imageView.sd_setImage(with: url)
```

## Screenshot

<img src="https://raw.githubusercontent.com/SDWebImage/SDWebImageBPGCoder/master/Example/Screenshot/BPGDemo.png" width="300" />

The images are from [BPG official site](https://bellard.org/bpg/)

## Author

DreamPiggy

## Thanks

[HCImage-BPG](https://github.com/chuganzy/HCImage-BPG)

## License

SDWebImageBPGCoder is available under the MIT license. See the LICENSE file for more info.


