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
  pod 'Firebase/Core', '~> 5.17.0'
  pod 'Firebase/DynamicLinks', '~> 5.17.0'
  pod 'Firebase/RemoteConfig', '~> 5.17.0'
  pod 'PhoneNumberKit', '~> 2.1'
  pod 'RxCocoa', '~> 4.0'
  pod 'RxSwift', '~> 4.0'
  pod 'Starscream', '~> 3.0.2'
  pod 'SwiftLint'
  pod 'stellar-ios-mac-sdk', git: 'git@github.com:jackpooleybc/stellar-ios-mac-sdk.git', commit: '4a86886656b0e89895d9fe89e004f5903359f333'

  pod 'VeriffSDK', '~> 2.0.4'

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
  pod 'stellar-ios-mac-sdk', git: 'git@github.com:jackpooleybc/stellar-ios-mac-sdk.git', commit: '4a86886656b0e89895d9fe89e004f5903359f333'
end

target 'EthereumKit' do
  pod 'RxSwift', '~> 4.0'
  pod 'RxCocoa', '~> 4.0'
  pod 'BigInt', '~> 3.1'
  pod 'web3swift.pod', '~> 2.1.10'

  target 'EthereumKitTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxSwift', '~> 4.0'
    pod 'RxCocoa', '~> 4.0'
    pod 'RxBlocking', '~> 4.0'
    pod 'RxTest', '~> 4.0'
    pod 'BigInt', '~> 3.1'
    pod 'web3swift.pod', '~> 2.1.10'
  end
end

target 'ERC20Kit' do
  pod 'RxSwift', '~> 4.0'
  pod 'RxCocoa', '~> 4.0'
  pod 'BigInt', '~> 3.1'
  pod 'web3swift.pod', '~> 2.1.10'

  target 'ERC20KitTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxSwift', '~> 4.0'
    pod 'RxBlocking', '~> 4.0'
    pod 'RxTest', '~> 4.0'
    pod 'BigInt', '~> 3.1'
    pod 'web3swift.pod', '~> 2.1.10'
  end
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
