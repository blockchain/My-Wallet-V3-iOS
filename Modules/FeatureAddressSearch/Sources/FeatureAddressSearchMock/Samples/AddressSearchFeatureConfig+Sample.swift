// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAddressSearchDomain
import Foundation

extension AddressSearchFeatureConfig {
    static func sample(
        addressSearchScreen: AddressSearchScreenConfig = .sample(),
        addressEditScreen: AddressEditScreenConfig = .sample()
    ) -> Self {
        AddressSearchFeatureConfig(
            addressSearchScreen: addressSearchScreen,
            addressEditScreen: addressEditScreen
        )
    }
}

extension AddressSearchFeatureConfig.AddressEditScreenConfig {
    static func sample(
        title: String = "title",
        subtitle: String? = "subtitle",
        saveAddressButtonTitle: String? = nil
    ) -> Self {
        AddressSearchFeatureConfig.AddressEditScreenConfig(
            title: title,
            subtitle: subtitle,
            saveAddressButtonTitle: saveAddressButtonTitle
        )
    }
}

extension AddressSearchFeatureConfig.AddressSearchScreenConfig {
    static func sample(
        title: String = "title",
        subtitle: String = "subtitle"
    ) -> Self {
        AddressSearchFeatureConfig.AddressSearchScreenConfig(
            title: title,
            subtitle: subtitle
        )
    }
}
