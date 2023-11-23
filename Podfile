source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '11.0'
use_frameworks!

abstract_target 'abstract-SwiftHook' do
  
  pod 'libffi-iOS', '~> 3.3.6-iOS', :inhibit_warnings => true
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
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
            end
        end
    end
end
