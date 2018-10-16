# Disable sending stats
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

# Uncomment the next line to define a global platform for your project
 platform :ios, '10.0'

target 'Blockchain' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!
  # Pods for Blockchain
    pod 'SwiftLint'
    pod 'Onfido', '~> 10.0.0'
    pod 'Alamofire', '~> 4.7'
    pod 'Charts', '~> 3.2.1'
    pod 'RxSwift', '~> 4.0'
    pod 'RxCocoa', '~> 4.0'
    pod 'PhoneNumberKit', '~> 2.1'
    pod 'Starscream', '~> 3.0.2'
    pod 'stellar-ios-mac-sdk', '~> 1.4.7'

  target 'BlockchainTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxBlocking', '~> 4.0'
    pod 'RxTest', '~> 4.0'
  end

end
post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
