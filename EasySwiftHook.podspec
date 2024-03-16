Pod::Spec.new do |spec|
  spec.name         = "EasySwiftHook"
  spec.version      = "3.5.2"
  spec.summary      = "A library to hook methods in Swift and Objective-C."
  spec.description  = <<-DESC
  A secure, simple, and efficient Swift/Objective-C hook library that dynamically modifies the methods of a specific object or all objects of a class. It supports both Swift and Objective-C and has excellent compatibility with Key-Value Observing (KVO).
  It’s based on Objective-C runtime and [libffi](https://github.com/libffi/libffi).
                   DESC

  spec.homepage     = "https://github.com/623637646/SwiftHook"
  spec.license      = "MIT"
  spec.author             = { "Yanni Wang 王氩" => "wy19900729@gmail.com" }
  spec.platforms = { :ios => "12.0", :osx => "10.13" }
  spec.swift_version = '5.0'
  spec.source       = { :git => "https://github.com/623637646/SwiftHook.git", :tag => spec.version.to_s }
  spec.source_files  = "SwiftHook/Classes/**/*.{h,m,swift}"
  spec.dependency 'libffi_apple', '~> 3.4.5'
end
