Pod::Spec.new do |s|
  s.name     = 'Tesla'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.summary  = 'Extensible Remote Logging for iOS.'
  s.homepage = 'https://github.com/mattt/Tesla'
  s.authors  = { 'Mattt Thompson' => 'm@mattt.me' }
  s.source   = { :git => 'https://github.com/mattt/Tesla.git', :tag => '0.0.1' }
  s.source_files = 'Tesla'
  s.requires_arc = true

  s.platform = :ios, '5.0'

  s.dependency 'AFNetworking', '~> 1.3'
end