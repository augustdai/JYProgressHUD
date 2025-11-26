Pod::Spec.new do |s|
  s.name             = 'JYProgressHUD'
  s.version          = '1.0.0'
  s.summary          = 'A modern iOS progress HUD library for iOS 17.0+'
  s.description      = <<-DESC
JYProgressHUD is a modern, Swift-based progress HUD library for iOS 17.0+.
It provides a clean and simple API for displaying progress indicators, labels, and custom views.
                       DESC

  s.homepage         = 'https://github.com/augustdai/JYProgressHUD'
  s.license          = { :type => 'Apache License 2.0', :file => 'LICENSE' }
  s.author           = { '上海即言软件开发有限公司' => 'augdai@163.com' }
  s.source           = { :git => 'https://github.com/augustdai/JYProgressHUD.git', :tag => s.version.to_s }

  s.ios.deployment_target = '17.0'
  s.swift_version = '5.9'

  s.source_files = 'JYProgressHUD/**/*.swift'
  s.frameworks = 'UIKit', 'Foundation', 'CoreGraphics', 'Combine'
  s.requires_arc = true
end

