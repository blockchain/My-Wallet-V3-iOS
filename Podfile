# Disable sending stats
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'
use_frameworks!

target 'Blockchain' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  inhibit_all_warnings!
  # Pods for Blockchain
  pod 'Alamofire', '~> 4.7'
  pod 'BigInt', '~> 3.1'
  pod 'Charts', '~> 3.2.1'
  pod 'Firebase/Core'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/RemoteConfig'
  pod 'PhoneNumberKit', '~> 2.1'
  pod 'RxCocoa', '~> 4.0'
  pod 'RxSwift', '~> 4.0'
  pod 'Starscream', '~> 3.0.2'
  pod 'SwiftLint'
  pod 'stellar-ios-mac-sdk', :git => 'https://github.com/thisisalexmcgregor/stellar-ios-mac-sdk', :commit => '672ec29bb3248eddd34878b694f773aa108c2528'
  pod 'VeriffSDK'

  target 'BlockchainTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxBlocking', '~> 4.0'
    pod 'RxTest', '~> 4.0'
  end
end

target 'StellarKit' do
    pod 'RxSwift', '~> 4.0'
    pod 'RxCocoa', '~> 4.0'
    pod 'stellar-ios-mac-sdk', :git => 'https://github.com/thisisalexmcgregor/stellar-ios-mac-sdk', :commit => '672ec29bb3248eddd34878b694f773aa108c2528'

end

target 'PlatformKit' do
    inhibit_all_warnings!
    pod 'RxSwift', '~> 4.0'
    pod 'BigInt', '~> 3.1'
    
    target 'PlatformKitTests' do
        inherit! :search_paths
        # Pods for testing
        pod 'RxSwift', '~> 4.0'
        pod 'BigInt', '~> 3.1'
    end
end

# Post Installation:
# - Disable code signing for pods.
post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
      config.build_settings.delete('CODE_SIGNING_ALLOWED')
      config.build_settings.delete('CODE_SIGNING_REQUIRED')
  end
end
