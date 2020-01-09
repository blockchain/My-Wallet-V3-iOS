# Disable sending stats
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

target 'Blockchain' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  # Pods for Blockchain
  pod 'BigInt', '~> 4.0'
  pod 'Charts', '~> 3.4.0'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Firebase/Core', '~> 6.14.0'
  pod 'Firebase/DynamicLinks', '~> 6.14.0'
  pod 'Firebase/RemoteConfig', '~> 6.14.0'
  pod 'Firebase/Messaging', '~> 6.14.0'
  pod 'PhoneNumberKit', '~> 2.1'
  pod 'RxCocoa', '5.0'
  pod 'RxSwift', '5.0'
  pod 'SwiftLint', '0.30.1'
  pod 'stellar-ios-mac-sdk', git: 'git@github.com:thisisalexmcgregor/stellar-ios-mac-sdk.git', commit: '897f8acd327bb900aa97a6b92e602c6076e978bc'
  pod 'zxcvbn-ios', '1.0.4'

  target 'BlockchainTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'web3swift.pod', git: 'git@github.com:thisisalexmcgregor/web3swift.git', commit: '39abb613bef9f63f7bff5633172b3b474e54c165'
    pod 'RxBlocking', '~> 5.0'
    pod 'RxTest', '~> 5.0'
    pod 'SwiftCheck', '~> 0.12'
  end
end

target 'ToolKit' do
  pod 'RxSwift', '5.0'
  pod 'RxRelay', '5.0'
  pod 'BigInt', '~> 4.0'

  target 'ToolKitTests' do
    inherit! :search_paths
    # Pods for testing
  end
end

target 'LocalizationKit' do
  target 'LocalizationKitTests' do
    inherit! :search_paths
    # Pods for testing
  end
end

target 'NetworkKit' do
  pod 'RxSwift', '5.0'

  target 'NetworkKitTests' do
    inherit! :search_paths
    # Pods for testing
  end
end

target 'PlatformUIKit' do
  pod 'RxSwift', '5.0'
  pod 'RxCocoa', '5.0'
  pod 'zxcvbn-ios', '1.0.4'
  pod 'Charts', '~> 3.4.0'

  target 'PlatformUIKitTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxBlocking', '~> 5.0'
    pod 'RxTest', '~> 5.0'
  end
end

target 'StellarKit' do
  pod 'RxSwift', '5.0'
  pod 'RxCocoa', '5.0'
  pod 'stellar-ios-mac-sdk', git: 'git@github.com:thisisalexmcgregor/stellar-ios-mac-sdk.git', commit: '897f8acd327bb900aa97a6b92e602c6076e978bc'

  target 'StellarKitTests' do
    inherit! :search_paths
    pod 'SwiftCheck', '~> 0.12'
  end
end

target 'EthereumKit' do
  pod 'RxSwift', '5.0'
  pod 'RxRelay', '5.0'
  pod 'BigInt', '~> 4.0'
  pod 'web3swift.pod', git: 'git@github.com:thisisalexmcgregor/web3swift.git', commit: '39abb613bef9f63f7bff5633172b3b474e54c165'

  target 'EthereumKitTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxBlocking', '~> 5.0'
    pod 'RxTest', '~> 5.0'
    pod 'SwiftCheck', '~> 0.12'
  end
end

target 'ERC20Kit' do
  pod 'RxSwift', '5.0'
  pod 'RxCocoa', '5.0'
  pod 'BigInt', '~> 4.0'
  pod 'web3swift.pod', git: 'git@github.com:thisisalexmcgregor/web3swift.git', commit: '39abb613bef9f63f7bff5633172b3b474e54c165'

  target 'ERC20KitTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxBlocking', '~> 5.0'
    pod 'RxTest', '~> 5.0'
    pod 'SwiftCheck', '~> 0.12'
  end
end

target 'BitcoinKit' do
  pod 'RxSwift', '5.0'
  pod 'BigInt', '~> 4.0'
  pod 'LibWally', git: 'git@github.com:blockchain/libwally-swift.git', :branch => 'master', :submodules => true

  target 'BitcoinKitTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxBlocking', '~> 5.0'
    pod 'RxTest', '~> 5.0'
    pod 'SwiftCheck', '~> 0.12'
  end
end

target 'HDWalletKit' do
  pod 'BigInt', '~> 4.0'
  pod 'LibWally', git: 'git@github.com:blockchain/libwally-swift.git', :branch => 'master', :submodules => true

  target 'HDWalletKitTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'SwiftCheck', '~> 0.12'
  end
end

target 'CommonCryptoKit' do
  pod 'BigInt', '~> 4.0'
  pod 'LibWally', git: 'git@github.com:blockchain/libwally-swift.git', :branch => 'master', :submodules => true

  target 'CommonCryptoKitTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'SwiftCheck', '~> 0.12'
  end
end

target 'PlatformKit' do
  pod 'RxSwift', '5.0'
  pod 'RxRelay', '5.0'
  pod 'RxCocoa', '5.0'
  pod 'BigInt', '~> 4.0'

  target 'PlatformKitTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'SwiftCheck', '~> 0.12'
    pod 'RxBlocking', '~> 5.0'
    pod 'RxTest', '~> 5.0'
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
