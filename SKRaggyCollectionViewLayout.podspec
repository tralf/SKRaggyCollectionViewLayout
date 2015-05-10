Pod::Spec.new do |s|

  s.name         = "SKRaggyCollectionViewLayout"
  s.version      = "1.0.0"
  s.summary      = "Custom UICollectionViewLayout for layout with horizontal scrolling, fixed cell height and variable cell width."
  s.homepage     = "https://github.com/tralf/SKRaggyCollectionViewLayout"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "Viktor Kalinchuk" => "viktor.kalinchuk@gmail.com" }

  s.ios.deployment_target = "6.0"

  s.source       = { :git => "https://github.com/maximkhatskevich/SKRaggyCollectionViewLayout.git", :tag => "#{s.version}" }
  
  s.framework = "UIKit"
  s.requires_arc = true

  s.source_files  = "Src/*.{h,m}"

end
