#
# Be sure to run `pod lib lint AppsOnAir-AppRemark.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AppsOnAir-AppRemark'
  s.version          = '0.1.0'
  s.summary          = 'AppsOnAir AppRemark'

  s.description      = 'Appsonair services for user feedback submission.'

  s.homepage         = 'https://documentation.appsonair.com/Mobile-Quickstart/ios-sdk-setup/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'devtools-logicwind' => 'devtools@logicwind.com' }
  s.source           = { :git => 'https://github.com/apps-on-air/AppsOnAir-iOS-AppRemark.git', :tag => s.version.to_s }

  s.swift_version  = '5.0'
  s.ios.deployment_target = '12.0'

  s.dependency 'IQKeyboardManagerSwift', '~> 6.5.16'
  s.dependency 'iOSDropDown'
  s.dependency 'Toast-Swift'
  s.dependency 'ZLImageEditor'
  # AppsOnAir Core pod
  s.dependency 'AppsOnAir-Core'
  
  # Access the all the UI File within the pod 
  s.resource_bundles = {
    'AppsOnAir-AppRemark' => ['AppsOnAir-AppRemark/Assets/**/*']
  } # for access SwiftUI  inside Feedbacks 
  
  
  s.source_files = 'AppsOnAir-AppRemark/Classes/**/*'
  
end
