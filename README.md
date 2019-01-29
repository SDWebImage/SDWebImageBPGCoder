# SDWebImageBPGCoder

[![CI Status](http://img.shields.io/travis/SDWebImage/SDWebImageBPGCoder.svg?style=flat)](https://travis-ci.org/SDWebImage/SDWebImageBPGCoder)
[![Version](https://img.shields.io/cocoapods/v/SDWebImageBPGCoder.svg?style=flat)](http://cocoapods.org/pods/SDWebImageBPGCoder)
[![License](https://img.shields.io/cocoapods/l/SDWebImageBPGCoder.svg?style=flat)](http://cocoapods.org/pods/SDWebImageBPGCoder)
[![Platform](https://img.shields.io/cocoapods/p/SDWebImageBPGCoder.svg?style=flat)](http://cocoapods.org/pods/SDWebImageBPGCoder)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/SDWebImage/SDWebImageBPGCoder)

## What's for

This is a [SDWebImage](https://github.com/SDWebImage/SDWebImage) coder plugin to add [BPG Image Format](https://bellard.org/bpg/) support. Which is built based on the open-sourced [libbpg](https://github.com/mirrorer/libbpg) codec.

This BPG coder plugin currently support static BPG and animated BPG image decoding.

## Requirements

+ iOS 8.0
+ macOS 10.10
+ tvOS 9.0
+ watchOS 2.0

## Installation

#### CocoaPods

SDWebImageBPGCoder is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SDWebImageBPGCoder'
```

#### Carthage

SDWebImageBPGCoder is available through [Carthage](https://github.com/Carthage/Carthage). Which use libbpg as dynamic framework.

```
github "SDWebImage/SDWebImageBPGCoder"
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

[libbpg](https://github.com/mirrorer/libbpg)

## License

SDWebImageBPGCoder is available under the MIT license. See the LICENSE file for more info.


