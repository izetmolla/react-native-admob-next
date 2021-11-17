require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))
version = package['version']

Pod::Spec.new do |s|
  s.name                   = 'react-native-admob-next'
  s.version                = version
  s.summary                = 'A react-native component for Google AdMob banners'
  s.homepage               = 'https://github.com/izetmolla/react-native-admob-next'
  s.license                = package['license']
  s.author                 = 'Izet Molla <izetmolla@gmail.com>'
  s.platform               = :ios, '9.0'
  s.source                 = { :git => 'https://github.com/izetmolla/react-native-admob-next.git', :tag => "v#{version}" }
  s.source_files           = 'ios/*.{h,m}'

  # We can't add the Google-Mobile-Ads-SDK as a dependency, as it would prevent
  # this library to be used with `use_frameworks!`.
  # So instead we add the default location of the framework to the framework
  # search paths, and we rely on consumers of this library to add
  # Google-Mobile-Ads-SDK as a direct dependency.
  # s.weak_frameworks        = 'GoogleMobileAds'
  s.dependency 'Google-Mobile-Ads-SDK', "8.12.0"
  # s.dependency 'GoogleMobileAds'


  s.pod_target_xcconfig    = {
    'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/Google-Mobile-Ads-SDK/Frameworks/**"',
  }

  s.dependency 'React'
end
