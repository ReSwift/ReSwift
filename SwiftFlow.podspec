Pod::Spec.new do |s|
  s.name             = "SwiftFlow"
  s.version          = "0.2.2"
  s.summary          = "Unidirectional Data Flow in Swift"
  s.description      = <<-DESC
                        Swift Flow is a Redux-like implementation of the unidirectional data flow architecture in Swift.
                        It embraces a unidirectional data flow that only allows state mutations through declarative actions.
                        DESC
  s.homepage         = "https://github.com/Swift-Flow/Swift-Flow"
  s.license          = { :type => "MIT", :file => "LICENSE.md" }
  s.author           = { "Benjamin Encz" => "me@benjamin-encz.de" }
  s.social_media_url = "http://twitter.com/benjaminencz"
  s.source           = { :git => "https://github.com/Swift-Flow/Swift-Flow.git", :tag => s.version.to_s }
  s.ios.deployment_target     = '8.0'
  s.osx.deployment_target     = '10.10'
  s.tvos.deployment_target    = '9.0'
  s.watchos.deployment_target = '2.0'
  s.requires_arc = true
  s.source_files     = 'SwiftFlow/**/*.swift'
end
