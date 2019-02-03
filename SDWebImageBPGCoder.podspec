#
# Be sure to run `pod lib lint SDWebImageBPGCoder.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SDWebImageBPGCoder'
  s.version          = '0.4.0'
  s.summary          = 'BPG decoder for SDWebImage plugin coder.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/SDWebImage/SDWebImageBPGCoder'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'DreamPiggy' => 'lizhuoli1126@126.com' }
  s.source           = { :git => 'https://github.com/SDWebImage/SDWebImageBPGCoder.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.default_subspecs = 'libbpg'
  s.module_map = 'SDWebImageBPGCoder/Module/SDWebImageBPGCoder.modulemap'

  s.subspec 'libbpg' do |ss|
    ss.source_files = 'SDWebImageBPGCoder/Classes/SDImageBPGCoder.{h,m}', 'SDWebImageBPGCoder/Module/SDWebImageBPGCoder.h', 'Vendor/libbpg/include/libbpg.h'
    ss.public_header_files = 'SDWebImageBPGCoder/Classes/SDImageBPGCoder.h', 'SDWebImageBPGCoder/Module/SDWebImageBPGCoder.h', 'Vendor/libbpg/include/libbpg.h'
    ss.osx.vendored_libraries = 'Vendor/libbpg/lib/mac/libbpg.a'
    ss.ios.vendored_libraries = 'Vendor/libbpg/lib/ios/libbpg.a'
    ss.tvos.vendored_libraries = 'Vendor/libbpg/lib/tvos/libbpg.a'
    ss.watchos.vendored_libraries = 'Vendor/libbpg/lib/watchos/libbpg.a'
  end

  s.subspec 'bpgenc' do |ss|
    ss.dependency 'SDWebImageBPGCoder/libbpg'
    ss.dependency 'libx265'
    ss.source_files = 'SDWebImageBPGCoder/Classes/bpgenc/*'
    ss.public_header_files = 'SDWebImageBPGCoder/Classes/bpgenc/*.h'
    ss.xcconfig = {
      'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) USE_X265=1',
      'WARNING_CFLAGS' => '$(inherited) -Wno-shorten-64-to-32 -Wno-conditional-uninitialized -Wno-unused-variable'
    }
  end

  s.dependency 'SDWebImage/Core', '>= 5.0.0-beta4'
end
