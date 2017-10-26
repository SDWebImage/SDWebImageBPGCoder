# SDWebImageBPGCoder

[![CI Status](http://img.shields.io/travis/dreampiggy/SDWebImageBPGCoder.svg?style=flat)](https://travis-ci.org/dreampiggy/SDWebImageBPGCoder)
[![Version](https://img.shields.io/cocoapods/v/SDWebImageBPGCoder.svg?style=flat)](http://cocoapods.org/pods/SDWebImageBPGCoder)
[![License](https://img.shields.io/cocoapods/l/SDWebImageBPGCoder.svg?style=flat)](http://cocoapods.org/pods/SDWebImageBPGCoder)
[![Platform](https://img.shields.io/cocoapods/p/SDWebImageBPGCoder.svg?style=flat)](http://cocoapods.org/pods/SDWebImageBPGCoder)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 8 or macOS 10.10

## Installation

SDWebImageBPGCoder is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SDWebImageBPGCoder'
```

## Usage

```objective-c
SDWebImageBPGCoder *BPGCoder = [SDWebImageBPGCoder sharedCoder];
[[SDWebImageCodersManager sharedInstance] addCoder:BPGCoder];
UIImageView *imageView;
NSURL *BPGURL;
[imageView sd_setImageWithURL:BPGURL];
```

## Screenshot

<img src="https://raw.githubusercontent.com/dreampiggy/SDWebImageBPGCoder/master/Example/Screenshot/BPGDemo.png" width="300" />

The images are from [BPG official site](https://bellard.org/bpg/)

## Author

DreamPiggy

## Thanks

[HCImage-BPG](https://github.com/chuganzy/HCImage-BPG)

## License

SDWebImageBPGCoder is available under the MIT license. See the LICENSE file for more info.
