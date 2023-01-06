// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import WalletPayloadKit

struct HDWalletResponse: Equatable, Codable {
    let seedHex: String
    let passphrase: String
    let mnemonicVerified: Bool
    let defaultAccountIndex: Int
    let accounts: [AccountResponse]

    enum CodingKeys: String, CodingKey {
        case seedHex = "seed_hex"
        case passphrase
        case mnemonicVerified = "mnemonic_verified"
        case defaultAccountIndex = "default_account_idx"
        case accounts
    }

    init(
        seedHex: String,
        passphrase: String,
        mnemonicVerified: Bool,
        defaultAccountIndex: Int,
        accounts: [AccountResponse]
    ) {
        self.seedHex = seedHex
        self.passphrase = passphrase
        self.mnemonicVerified = mnemonicVerified
        self.defaultAccountIndex = defaultAccountIndex
        self.accounts = accounts
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.seedHex = try container.decode(String.self, forKey: .seedHex)
        self.passphrase = try container.decodeIfPresent(String.self, forKey: .passphrase) ?? ""
        self.mnemonicVerified = try container.decodeIfPresent(Bool.self, forKey: .mnemonicVerified) ?? false
        // default to `0` is `default_account_idx` is missing
        self.defaultAccountIndex = try container.decodeIfPresent(Int.self, forKey: .defaultAccountIndex) ?? 0

        // attempt to decode version4 first and then version3, if both fail then an error will be thrown
        do {
            let accountsVersion4 = try container.decode([AccountWrapper.Version4].self, forKey: .accounts)
            self.accounts = try decodeAccounts(
                using: accountWrapperDecodingStrategy(version4:),
                value: accountsVersion4
            )
            .get()
        } catch is DecodingError {
            let accountsVersion3 = try container.decode([AccountWrapper.Version3].self, forKey: .accounts)
            self.accounts = try decodeAccounts(
                using: accountWrapperDecodingStrategy(version3:),
                value: accountsVersion3
            )
            .get()
        }
    }
}

extension WalletPayloadKit.HDWallet {
    static func from(model: HDWalletResponse) -> HDWallet {
        HDWallet(
            seedHex: model.seedHex,
            passphrase: model.passphrase,
            mnemonicVerified: model.mnemonicVerified,
            defaultAccountIndex: model.defaultAccountIndex,
            accounts: model.accounts.enumerated().map { index, model in
                WalletPayloadKit.Account.from(model: model, index: index)
            }
        )
    }

    var toHDWalletResponse: HDWalletResponse {
        HDWalletResponse(
            seedHex: seedHex,
            passphrase: passphrase,
            mnemonicVerified: mnemonicVerified,
            defaultAccountIndex: defaultAccountIndex,
            accounts: accounts.map(\.toAccountResponse)
        )
    }
}
