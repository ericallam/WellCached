#
# Be sure to run `pod spec lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "WellCached"
  s.version          = "0.1.0"
  s.summary          = "An expiring, thread-safe caching library based on NSCache"
  s.description      = <<-DESC
                        WellCached provides a simple NSDictionary-like interface for caching, allowing
                        you to automatically expire cached items after a specific period. You can set the expiring
                        duration on a case-by-case basis. You can also set a race-condition-ttl to prevent cache misses
                        across threads on the same key to all attempt to generate new data.
                       DESC
  s.homepage         = "http://github.com/ericallam/WellCached"
  s.license          = 'MIT'
  s.author           = { "Eric Allam" => "eallam@icloud.com" }
  s.source           = { :git => "http://github.com/ericallam/WellCached.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/eallam'

  # s.platform     = :ios, '5.0'
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = true

  s.source_files = 'WellCached'
  s.public_header_files = 'WellCached/**/*.h'
end
