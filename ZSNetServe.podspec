#
# Be sure to run `pod lib lint ZSNetServe.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZSNetServe'
  s.version          = '0.0.2'
  s.summary          = '基于Alamofire的网络请求框架'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
基于Alamofire的网络请求框架二次封装
                       DESC

  s.homepage         = 'https://github.com/zhangsen093725/ZSNetServe'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zhangsen093725' => '376019018@qq.com' }
  s.source           = { :git => 'https://github.com/zhangsen093725/ZSNetServe.git', :tag => s.version.to_s }
  s.swift_version    = '5.0'
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ZSNetServe/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ZSNetServe' => ['ZSNetServe/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Alamofire'
end
