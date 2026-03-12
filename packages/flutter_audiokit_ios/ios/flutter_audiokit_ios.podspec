Pod::Spec.new do |s|
  s.name             = 'flutter_audiokit_ios'
  s.version          = '0.1.0'
  s.summary          = 'iOS implementation of flutter_audiokit using AudioKit.'
  s.description      = <<-DESC
iOS platform implementation of the flutter_audiokit plugin.
Wraps AudioKit and SoundpipeAudioKit via Pigeon-generated platform channels.
                       DESC
  s.homepage         = 'https://github.com/user/flutter_audiokit'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Author' => 'author@example.com' }
  s.source           = { :http => 'https://github.com/user/flutter_audiokit' }
  s.source_files     = 'flutter_audiokit_ios/Sources/flutter_audiokit_ios/**/*.swift'
  s.dependency 'Flutter'
  s.platform         = :ios, '15.0'
  s.swift_version    = '5.9'

  # AudioKit dependencies via CocoaPods
  # Note: AudioKit primarily uses SPM, but CocoaPods specs are available
  # If using SPM, configure via Package.swift instead
  # s.dependency 'AudioKit', '~> 5.6'
  # s.dependency 'SoundpipeAudioKit', '~> 5.6'
end
