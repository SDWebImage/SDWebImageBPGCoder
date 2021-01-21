# SDWebImageBPGCoder

[![CI Status](http://img.shields.io/travis/SDWebImage/SDWebImageBPGCoder.svg?style=flat)](https://travis-ci.org/SDWebImage/SDWebImageBPGCoder)
[![Version](https://img.shields.io/cocoapods/v/SDWebImageBPGCoder.svg?style=flat)](http://cocoapods.org/pods/SDWebImageBPGCoder)
[![License](https://img.shields.io/cocoapods/l/SDWebImageBPGCoder.svg?style=flat)](http://cocoapods.org/pods/SDWebImageBPGCoder)
[![Platform](https://img.shields.io/cocoapods/p/SDWebImageBPGCoder.svg?style=flat)](http://cocoapods.org/pods/SDWebImageBPGCoder)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/SDWebImage/SDWebImageBPGCoder)

## What's for

This is a [SDWebImage](https://github.com/SDWebImage/SDWebImage) coder plugin to add [BPG Image Format](https://bellard.org/bpg/) support. Which is built based on the open-sourced [libbpg](https://github.com/mirrorer/libbpg) codec.

This BPG coder plugin support static BPG and animated BPG image decoding. It also include an optional codec based on the `bpgenc` to support static BPG and animated BPG encoding.

## Requirements

+ iOS 9.0
+ macOS 10.11
+ tvOS 9.0
+ watchOS 2.0

## Installation

#### CocoaPods

SDWebImageBPGCoder is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SDWebImageBPGCoder'
```

SDWebImageBPGCoder contains subspecs `libbpg` & `bpgenc`. Which integrate the codec plugin for libbpg and custom bpgenc to support BPG image decoding/encoding.

To enable BPG decoding, you should add `libbpg` subspec:

```ruby
pod 'SDWebImageBPGCoder/libbpg'
```

To enable BPG encoding, you should add `bpgenc` subspec:

```ruby
pod 'SDWebImageBPGCoder/bpgenc'
```

By default will contains only `libbpg` subspec for most people's usage. Using `bpgenc` encoding subspec only if you want BPG encoding.

#### Carthage

SDWebImageBPGCoder is available through [Carthage](https://github.com/Carthage/Carthage). Which use libbpg as dynamic framework.

Carthage does not support like CocoaPods' subspec, since most of user use BPG decoding without x265 library. The framework through Carthage only supports libbpg for BPG decoding.

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

`SDWebImageBPGCoder` also support BPG encoding (need bpgenc subspec). You can encode `UIImage` to BPG compressed image data.

+ Objective-C

```objectivec
UIImage *image;
NSData *imageData = [image sd_imageDataAsFormat:SDImageFormatBPG];
```

+ Swift

```swift
let image;
let imageData = image.sd_imageData(as: .BPG)
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

However, when using `bpgenc`, the license will be subject to GPL licence (or commercial licence if you have one). Because we use x265, and use a modified version of `bpgenc` (which is GPL). Check [x265.org](http://x265.org/) and [libbpg](https://github.com/mirrorer/libbpg) for more information.


