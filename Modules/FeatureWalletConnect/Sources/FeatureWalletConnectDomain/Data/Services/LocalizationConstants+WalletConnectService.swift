// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization

extension LocalizationConstants {
    enum WalletConnect {
        enum ServiceError {
            static let missingSession = NSLocalizedString(
                "We couldn't find the session requested",
                comment: "We couldn't find the session requested"
            )

            static let unknownNetwork = NSLocalizedString(
                "The dApp requested to use an unsupported network",
                comment: "The dApp requested to use an unsupported network"
            )

            static let invalidTxTarget = NSLocalizedString(
                "We couldn't create a transaction target based on dApp message",
                comment: "We couldn't create a transaction target based on dApp message"
            )

            static let unsupportedMethod = NSLocalizedString(
                "The dApp tried to use an unsupported method",
                comment: "The dApp tried to use an unsupported method"
            )

            static let unknown = NSLocalizedString(
                "An unknown failure occured",
                comment: "An unknown failure occured"
            )
        }
    }
}
