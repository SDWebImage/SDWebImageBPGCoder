#
# Be sure to run `pod lib lint SDWebImageBPGCoder.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SDWebImageBPGCoder'
  s.version          = '0.2.2'
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

  s.source_files = 'SDWebImageBPGCoder/Classes/**/*', 'Vendor/libbpg/include/libbpg.h', 'SDWebImageBPGCoder/Module/SDWebImageBPGCoder.h'
  s.module_map = 'SDWebImageBPGCoder/Module/SDWebImageBPGCoder.modulemap'
  s.public_header_files = 'SDWebImageBPGCoder/Classes/**/*.h', 'SDWebImageBPGCoder/Module/SDWebImageBPGCoder.h'
  s.osx.vendored_libraries = 'Vendor/libbpg/lib/mac/libbpg.a'
  s.ios.vendored_libraries = 'Vendor/libbpg/lib/ios/libbpg.a'
  s.dependency 'SDWebImage/Core', '>= 5.0.0-beta4'
end
