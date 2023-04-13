// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension LocalizationConstants {
    public enum WalletPayloadKit {}
}

extension LocalizationConstants.WalletPayloadKit {
    public enum Error {
        public static let unknown = NSLocalizedString(
            "Something went wrong.",
            comment: "Something went wrong."
        )
        public static let internalPayloadError = NSLocalizedString(
            "An internal error occurred, code: %@",
            comment: "An internal error occurred, code: %@"
        )

        public static let accountCreationFailed = NSLocalizedString(
            "We are unable to create your wallet. Please, try again later.",
            comment: "We are unable to create your wallet. Please, try again later."
        )

        public static let decryptionFailed = NSLocalizedString(
            "Error decrypting wallet, please check that your password is correct",
            comment: "Error decrypting wallet, please check that your password is correct"
        )

        public static let payloadNotFound = NSLocalizedString(
            "Failed to retrieve wallet due to missing payload data.",
            comment: "Failed to retrieve wallet due to missing payload data."
        )
    }

    public enum PasswordChangeAlert {
        public static let passwordRequiredTitle = NSLocalizedString(
            "Password required",
            comment: "Password required"
        )

        public static let passwordRequiredMessage = NSLocalizedString(
            "Error decrypting wallet. Tap 'Log Out' to re-enter your password.",
            comment: "Error decrypting wallet. Tap 'Log Out' to re-enter your password."
        )

        public static let logOutButtonTitle = NSLocalizedString(
            "Log Out",
            comment: "Log Out"
        )
    }

    // MARK: WalletInitializationError

    public enum WalletInitializationConstants {
        public static let unknown = NSLocalizedString(
            "Wallet initialization failed due to an unknown error, please try again.",
            comment: "Wallet initialization failed due to an unknown error, please try again."
        )

        public static let missingWallet = NSLocalizedString(
            "Wallet initialization failed due to missing data",
            comment: "Wallet initialization failed due to missing data"
        )

        public static let missingSeedHex = NSLocalizedString(
            "Wallet initialization failed due to missing seedHex",
            comment: "Wallet initialization failed due to missing seedHex"
        )

        public static let metadataInitialization = NSLocalizedString(
            "Wallet initialization failed due to metadata error: %@",
            comment: "Wallet initialization failed due to metadata error:"
        )

        public static let needsSecondPassword = NSLocalizedString(
            "Wallet initialization failed due to being double encrypted",
            comment: "Wallet initialization failed due to being double encrypted"
        )

        public static let invalidSecondPassword = NSLocalizedString(
            "Wallet initialization failed due to being second password being invalid",
            comment: "Wallet initialization failed due to being second password being invalid"
        )
    }

    // MARK: WalletRecoverError

    public enum WalletRecoverErrorConstants {
        public static let unknown = NSLocalizedString(
            "Wallet recovery failed due to an uknown error",
            comment: "Wallet recovery failed due to an uknown error"
        )

        public static let invalidMnemonic = NSLocalizedString(
            "Wallet recovery failure due to an invalid mnemonic",
            comment: "Wallet recovery failure due to an invalid mnemonic"
        )

        public static let failedToRecoverWallet = NSLocalizedString(
            "Wallet recovery failed due to an uknown legacy error",
            comment: "Wallet recovery failed due to an uknown legacy error"
        )
    }

    public enum WalletEncodingErrorConstants {
        public static let encryptionFailure = NSLocalizedString(
            "Wallet failure due to encryption error",
            comment: "Wallet failure due to encryption error"
        )
        public static let encodingError = NSLocalizedString(
            "Wallet failure due to encoding error: %@",
            comment: "Wallet failure due to encoding error"
        )
        public static let genericFailure = NSLocalizedString(
            "Wallet initialization failed due to an unknown error",
            comment: "Wallet initialization failed due to an unknown error"
        )
        public static let expectedEncryptedPayload = NSLocalizedString(
            "Wallet initialization failed, expected an encrypted payload got encoded",
            comment: "Wallet initialization failed, expected an encrypted payload got encoded"
        )
    }

    public enum EncryptAndVerifyErrorConstants {
        public static let expectedEncryptedPayload = NSLocalizedString(
            "Wallet encrypting failed, expected an encrypted payload got encoded",
            comment: "Wallet initialization failed, expected an encrypted payload got encoded"
        )

        public static let encryptionFailure = NSLocalizedString(
            "Wallet failure due to encryption error",
            comment: "Wallet failure due to encryption error"
        )
    }
}
