// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Localization
import UIKit

typealias L10n = LocalizationConstants.WalletConnect

public enum EventConnectionState: Codable, Equatable {
    case request
    case success

    var mainButtonAction: (L & I_blockchain_ui_type_task)? {
        switch self {
        case .request:
            return blockchain.ux.wallet.connect.pair.request.accept
        case .success:
            return nil
        }
    }

    var secondaryButtonAction: (L & I_blockchain_ui_type_task)? {
        switch self {
        case .request:
            return blockchain.ux.wallet.connect.pair.request.declined
        case .success:
            return nil
        }
    }

    var mainButtonTitle: String? {
        switch self {
        case .request:
            return L10n.confirm
        case .success:
            return nil
        }
    }

    var secondaryButtonTitle: String? {
        switch self {
        case .request:
            return L10n.cancel
        case .success:
            return nil
        }
    }

    var decorationImage: UIImage? {
        switch self {
        case .request:
            return nil
        case .success:
            return UIImage(
                named: "success-decorator",
                in: .featureWalletConnectUI,
                with: nil
            )
        }
    }
}
