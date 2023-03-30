#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint iterable_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'iterable_flutter'
  s.version          = '0.6.1'
  s.summary          = 'Flutter implementation for iterable.com Cross Channel Marketing Platform'
  s.description      = <<-DESC
  Flutter implementation for iterable.com Cross Channel Marketing Platform
                       DESC
  s.homepage         = 'https://github.com/la-haus/iterable-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'La Haus' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Iterable-iOS-SDK', '6.4.12'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
