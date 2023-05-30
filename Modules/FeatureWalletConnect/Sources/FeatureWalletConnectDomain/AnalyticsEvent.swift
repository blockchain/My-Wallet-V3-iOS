// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation

public typealias AnalyticsWalletConnect = AnalyticsEvents.New.WalletConnect

extension AnalyticsEvents.New {
    public enum WalletConnect: AnalyticsEvent {

        // MARK: - Types

        public enum Action: String, StringRawRepresentable {
            case confirm = "CONFIRM"
            case cancel = "CANCEL"
        }

        public enum Method: String, StringRawRepresentable {
            case sendRawTransaction = "ETH_SEND_RAW_TRANSACTION"
            case sendTransaction = "ETH_SEND_TRANSACTION"
            case sign = "ETH_SIGN"
            case signTransaction = "ETH_SIGN_TRANSACTION"
            case signTypedData = "ETH_SIGN_TYPED_DATA"
            case personalSign = "PERSONAL_SIGN"
        }

        public enum DappClickOrigin: String, StringRawRepresentable {
            case appsList = "APPS_LIST"
        }

        public enum DappsListOrigin: String, StringRawRepresentable {
            case qrCode = "QR_CODE"
            case settings = "SETTINGS"
        }

        public enum DappAction: String, StringRawRepresentable {
            case disconnect = "DISCONNECT"
            case launch = "LAUNCH"
        }

        // MARK: - Events

        // MARK: Connected Dapps List

        /// The list of connected Apps is clicked.
        case connectedDappsListClicked(
            origin: DappsListOrigin
        )

        /// The list of connected Apps is viewed.
        case connectedDappsListViewed

        // MARK: Connected Dapp

        /// The user clicks on some actions that the user can take after clicking on an app.
        case connectedDappActioned(
            action: DappAction,
            appName: String,
            origin: DappClickOrigin
        )

        /// A button to view a connected app is clicked
        case connectedDappClicked(
            appName: String,
            origin: DappClickOrigin
        )

        // MARK: Dapp Connection

        /// The user takes some actions in the dapp connection prompt.
        case dappConnectionActioned(
            action: Action,
            appName: String
        )

        /// The app connection to a new app was confirmed. This means the app is now connected to the blockchain wallet.
        case dappConnectionConfirmed(
            appName: String
        )

        /// The app connection to a new app was rejected.
        case dappConnectionRejected(
            appName: String
        )

        // MARK: Dapp Request

        /// The user actions on a request from a connected dapp. it could be for example for signing a transaction.
        case dappRequestActioned(
            action: Action,
            appName: String,
            method: Method
        )

        // MARK: - AnalyticsEvent

        public var type: AnalyticsEventType { .nabu }
    }
}
