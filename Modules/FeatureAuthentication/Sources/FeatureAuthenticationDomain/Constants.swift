// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

public enum Constants {

    private static let blockchainHost: String = InfoDictionaryHelper.value(for: .blockchainUrl)
    private static let loginHost: String = InfoDictionaryHelper.value(for: .loginUrl)

    // blockchain host with fallback
    private static var normalizedBlockchainHost: String {
        let baseURL = blockchainHost
        guard !baseURL.isEmpty else {
            return "blockchain.com"
        }
        return baseURL
    }

    public enum HostURL {
        public static var resetTwoFA: String {
            "https://\(loginHost)/#/reset-2fa"
        }

        /// A url string that points to Blockchain login page
        public static var loginOnWeb: String {
            "https://\(loginHost)/#/login"
        }

        public static var recoverPassword: String {
            "https://\(loginHost)/en/#/recover"
        }
        public static var terms: String {
            "https://\(normalizedBlockchainHost)/legal/terms"
        }

        public static var privacyPolicy: String {
            "https://\(normalizedBlockchainHost)/legal/privacy"
        }
    }

    public enum SupportURL {
        public enum ForgotPassword {
            public static let supportLink = "https://support.blockchain.com/hc/en-us/articles/211205343-I-forgot-my-password-What-can-you-do-to-help-"
        }

        public enum ResetPassword {
            public static let identityVerificationOverview =
                "https://support.blockchain.com/hc/en-us/articles/360018080172-Identity-Verification-Overview"
        }

        public enum SecondPassword {
            /// A url string that points to Blockchain support page for enabling 2FA
            public static let twoFASupport = "https://support.blockchain.com/hc/en-us/articles/211164103"
        }

        public enum ResetAccount {
            public static var walletBackupURL: URL {
                "https://support.blockchain.com/hc/en-us/articles/209564506-Make-a-Wallet-Backup"
            }

            public static let recoveryFailureSupport = "https://support.blockchain.com/hc/en-us/requests/new?ticket_form_id=360003112491"
            public static let learnMore = "https://support.blockchain.com/hc/en-us/articles/4404679303700"
            public static let contactSupport = "https://support.blockchain.com/hc/en-us"
        }

        public enum PIN {
            public static let contactUs = "https://support.blockchain.com/hc/en-us/requests/new"
            public static let viewFAQ = "https://support.blockchain.com/hc/en-us/categories/4416659837460-Wallet"
        }
    }
}

class FeatureAuthenticationDomainBundle {}

private enum InfoDictionaryHelper {
    enum Key: String {
        case loginUrl = "LOGIN_URL"
        case blockchainUrl = "BLOCKCHAIN_URL"
    }

    private static let infoDictionary = MainBundleProvider.mainBundle.infoDictionary

    static func value(for key: Key) -> String! {
        infoDictionary?[key.rawValue] as? String
    }

    static func value(for key: Key, prefix: String) -> String! {
        guard let value = value(for: key) else {
            return nil
        }
        return prefix + value
    }
}
