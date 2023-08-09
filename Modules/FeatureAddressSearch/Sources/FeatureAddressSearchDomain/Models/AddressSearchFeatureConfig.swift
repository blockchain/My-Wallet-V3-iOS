// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct AddressSearchFeatureConfig {

    public struct AddressSearchScreenConfig {
        public let title: String
        public let subtitle: String

        public init(
            title: String,
            subtitle: String
        ) {
            self.title = title
            self.subtitle = subtitle
        }
    }

    public struct AddressEditScreenConfig {
        public let title: String
        public let subtitle: String?
        public let saveAddressButtonTitle: String?
        public let shouldSaveAddressOnCompletion: Bool

        public init(
            title: String,
            subtitle: String? = nil,
            saveAddressButtonTitle: String? = nil,
            shouldSaveAddressOnCompletion: Bool = true
        ) {
            self.title = title
            self.subtitle = subtitle
            self.saveAddressButtonTitle = saveAddressButtonTitle
            self.shouldSaveAddressOnCompletion = shouldSaveAddressOnCompletion
        }
    }

    public let addressSearchScreen: AddressSearchScreenConfig
    public let addressEditScreen: AddressEditScreenConfig

    public init(
        addressSearchScreen: AddressSearchScreenConfig,
        addressEditScreen: AddressEditScreenConfig
    ) {
        self.addressSearchScreen = addressSearchScreen
        self.addressEditScreen = addressEditScreen
    }
}
