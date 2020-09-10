#
# Be sure to run `pod lib lint JDGImagePicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JDGImagePicker'
  s.version          = '0.1.3'
  s.summary          = '基于Objective-C实现的相册相机选择器'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
基于Objective-C实现的相册相机选择器,支持相机和相册的同步选择
                       DESC

  s.homepage         = 'https://github.com/JDGan/JDGImagePicker.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'JDGan' => 'jessiegan1987@163.com' }
  s.source           = { :git => 'https://github.com/JDGan/JDGImagePicker.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'JDGImagePicker/Classes/Base/**/*.{h,m}'
  
  s.subspec 'ImagePicker' do |sub|
      sub.source_files = 'JDGImagePicker/Classes/ImagePicker/**/*.{h,m}'
      s.resource_bundles = {
        'JDGImagePickerResources' => ['JDGImagePicker/Assets/ImagePicker/*.{storyboard,xcassets}']
      }
  end
  
  s.subspec 'ImagePreviewer' do |sub|
      sub.source_files = 'JDGImagePicker/Classes/ImagePreviewer/**/*.{h,m}'
  end
  
  s.frameworks = 'UIKit', 'Photos', 'AVFoundation'
end
