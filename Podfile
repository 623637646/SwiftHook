platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

abstract_target 'abstract-SwiftHook' do
  
  pod 'libffi-iOS', '~> 3.3-iOS'
  
  target 'SwiftHook' do
  end
  
  abstract_target 'abstract-Tests' do
    pod 'Aspects'
    
    target 'SwiftHookTests' do
    end
    
    target 'PerformanceTests' do
    end
    
  end
  
end
