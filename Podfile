source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'
use_frameworks!

abstract_target 'abstract-SwiftHook' do
  
  pod 'libffi-iOS', '~> 3.3.3-iOS'
  pod 'SwiftLint'
  
  target 'SwiftHook' do
  end
  
  abstract_target 'abstract-Tests' do
    pod 'Aspects', :inhibit_warnings => true
    
    target 'SwiftHookTests' do
    end
    
    target 'PerformanceTests' do
    end
    
  end
  
end
