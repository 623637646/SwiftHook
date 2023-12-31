source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '12.0'
use_frameworks!

abstract_target 'abstract-SwiftHook' do
  
  pod 'libffi_apple', '~> 3.4.4', :inhibit_warnings => true
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

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
            end
        end
    end
end
