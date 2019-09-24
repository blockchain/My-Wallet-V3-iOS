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
  pod 'Charts', '~> 3.2.1'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Firebase/Core', '~> 5.17.0'
  pod 'Firebase/DynamicLinks', '~> 5.17.0'
  pod 'Firebase/RemoteConfig', '~> 5.17.0'
  pod 'Firebase/Messaging'
  pod 'PhoneNumberKit', '~> 2.1'
  pod 'RxCocoa', '5.0'
  pod 'RxSwift', '5.0'
  pod 'Starscream', '3.1.0'
  pod 'SwiftLint', '0.30.1'
  pod 'stellar-ios-mac-sdk', git: 'git@github.com:thisisalexmcgregor/stellar-ios-mac-sdk.git', commit: '03aefcdc14a43a16c46b483ffaea90ce9c210071'
  pod 'VeriffSDK', '2.0.5'

  target 'BlockchainTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'web3swift.pod', git: 'git@github.com:thisisalexmcgregor/web3swift.git', commit: '39abb613bef9f63f7bff5633172b3b474e54c165'
    pod 'RxBlocking', '~> 5.0'
    pod 'RxTest', '~> 5.0'
  end
end

target 'PlatformUIKit' do
  pod 'RxSwift', '5.0'
  pod 'RxCocoa', '5.0'
end

target 'StellarKit' do
  pod 'RxSwift', '5.0'
  pod 'RxCocoa', '5.0'
  pod 'stellar-ios-mac-sdk', git: 'git@github.com:thisisalexmcgregor/stellar-ios-mac-sdk.git', commit: '03aefcdc14a43a16c46b483ffaea90ce9c210071'

  target 'StellarKitTests' do
    inherit! :search_paths
  end
end

target 'EthereumKit' do
  pod 'RxSwift', '5.0'
  pod 'RxCocoa', '5.0'
  pod 'BigInt', '~> 4.0'
  pod 'web3swift.pod', git: 'git@github.com:thisisalexmcgregor/web3swift.git', commit: '39abb613bef9f63f7bff5633172b3b474e54c165'

  target 'EthereumKitTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxSwift', '5.0'
    pod 'RxCocoa', '5.0'
    pod 'RxBlocking', '~> 5.0'
    pod 'RxTest', '~> 5.0'
    pod 'BigInt', '~> 4.0'
    pod 'web3swift.pod', git: 'git@github.com:thisisalexmcgregor/web3swift.git', commit: '39abb613bef9f63f7bff5633172b3b474e54c165'
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
    pod 'RxSwift', '5.0'
    pod 'RxBlocking', '~> 5.0'
    pod 'RxTest', '~> 5.0'
    pod 'BigInt', '~> 4.0'
    pod 'web3swift.pod', git: 'git@github.com:thisisalexmcgregor/web3swift.git', commit: '39abb613bef9f63f7bff5633172b3b474e54c165'
  end
end

target 'BitcoinKit' do
  pod 'RxSwift', '5.0'
  pod 'BigInt', '~> 4.0'
  pod 'LibWally', git: 'git@github.com:blockchain/libwally-swift.git', :branch => 'master', :submodules => true

  target 'BitcoinKitTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxSwift', '5.0'
    pod 'RxBlocking', '~> 5.0'
    pod 'RxTest', '~> 5.0'
    pod 'BigInt', '~> 4.0'
    pod 'LibWally', git: 'git@github.com:blockchain/libwally-swift.git', :branch => 'master', :submodules => true
  end
end

target 'HDWalletKit' do
  pod 'BigInt', '~> 4.0'
  pod 'LibWally', git: 'git@github.com:blockchain/libwally-swift.git', :branch => 'master', :submodules => true

  target 'HDWalletKitTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'BigInt', '~> 4.0'
    pod 'LibWally', git: 'git@github.com:blockchain/libwally-swift.git', :branch => 'master', :submodules => true
  end
end

target 'CommonCryptoKit' do
  pod 'BigInt', '~> 4.0'
  pod 'LibWally', git: 'git@github.com:blockchain/libwally-swift.git', :branch => 'master', :submodules => true

  target 'CommonCryptoKitTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'BigInt', '~> 4.0'
    pod 'LibWally', git: 'git@github.com:blockchain/libwally-swift.git', :branch => 'master', :submodules => true
  end
end

target 'PlatformKit' do
  pod 'RxSwift', '5.0'
  pod 'BigInt', '~> 4.0'

  target 'PlatformKitTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxSwift', '5.0'
    pod 'BigInt', '~> 4.0'
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
