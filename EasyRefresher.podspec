
Pod::Spec.new do |s|
  s.name             = 'EasyRefresher'
  s.version          = '0.5.5'
  s.summary          = 'A refresh control for UIScrollView.'
  s.homepage         = 'https://github.com/Pircate/EasyRefresher'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Pircate' => 'gao497868860@gmail.com' }
  s.source           = { :git => 'https://github.com/Pircate/EasyRefresher.git', :tag => s.version.to_s }
  s.source_files     = 'EasyRefresher/Classes/**/*'
  s.resource_bundles = { 'EasyRefresher' => ['EasyRefresher/Assets/*.xcassets'] }
  s.ios.deployment_target = '9.0'
  s.swift_versions = ['4.2', '5.0']
end
