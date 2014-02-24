#
# Be sure to run `pod spec lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "WellCached"
  s.version          = "0.1.0"
  s.summary          = "A short description of WellCached."
  s.description      = <<-DESC
                       An optional longer description of WellCached

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "http://github.com/ericallam/WellCached"
  s.license          = 'MIT'
  s.author           = { "Eric Allam" => "eallam@icloud.com" }
  s.source           = { :git => "http://github.com/ericallam/WellCached.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/eallam'

  # s.platform     = :ios, '5.0'
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = true

  s.source_files = 'WellCached'
  s.public_header_files = 'WellCached/**/*.h'
end
