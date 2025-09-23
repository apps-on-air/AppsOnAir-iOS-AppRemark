#
# Be sure to run `pod lib lint AppsOnAir-AppRemark.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AppsOnAir-AppRemark'
  s.version          = '1.1.1'
  s.summary          = 'AppsOnAir services for user feedback submission.'
  
  s.homepage         = 'https://documentation.appsonair.com/category/appremark-beta'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'devtools-logicwind' => 'devtools@logicwind.com' }
  s.source           = { :git => 'https://github.com/apps-on-air/AppsOnAir-iOS-AppRemark.git', :tag => s.version.to_s }

  s.swift_version  = '5.0'
  s.ios.deployment_target = '14.0'

  s.dependency 'IQKeyboardToolbarManager', '1.1.3'
  s.dependency 'iOSDropDown', '0.4.0'
  s.dependency 'Toast-Swift', '5.1.1'
  s.dependency 'LWPhotoEditor', '0.1.0'
  # AppsOnAir Core pod
  s.dependency 'AppsOnAir-Core', '1.1.1'
  
  # Access the all the UI File within the pod 
  s.resource_bundles = {
    'AppsOnAir-AppRemark' => ['AppsOnAir-AppRemark/Assets/**/*']
  } # for access SwiftUI  inside Feedbacks 
  
  
  s.source_files = 'AppsOnAir-AppRemark/Classes/**/*.{swift,h,m}'
  
end
