//
//  WalletUpgradeViewModel.swift
//  Blockchain
//
//  Created by Paulo on 17/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization

enum WalletUpgradeViewModel {
    private typealias LocalizedString = LocalizationConstants.WalletUpgrade

    case loading(version: String?)
    case success
    case error(version: String)

    private var message: String {
        switch self {
        case .loading(let version):
            if let version = version {
                return LocalizedString.upgradingVersion(version: version) + " " + LocalizedString.doNotClose
            }
            return LocalizedString.upgrading + " " + LocalizedString.doNotClose
        case .success:
            return ""
        case .error(let version):
            return LocalizedString.error(version: version)
        }
    }

    var labelContent: LabelContent {
        LabelContent(text: message, font: .main(.medium, 22), color: .white, alignment: .center, accessibility: .none)
    }

    var loadingIndicator: Visibility {
        switch self {
        case .loading:
            return .visible
        default:
            return .hidden
        }
    }
}
