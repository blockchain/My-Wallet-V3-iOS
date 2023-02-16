// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import EthereumKit
import PlatformKit
import TestKit

enum MockEthereumWalletTestData {
    static let walletId = MockWalletTestData.walletId
    static let email = MockWalletTestData.email

    static let mnemonic = MockWalletTestData.Bip39.mnemonic
    static let account = "0xE408d13921DbcD1CBcb69840e4DA465Ba07B7e5e"
    static let publicKeyHex = "04f364912f341a5f73e2c4fea1f83ebd15bf3107498cd11a5ae5d97c9a9e3ec3d2214dfd0dd388737a1fe9f1f0f32210ea364e8d2d885481dc1b3480be51430563"

    static let privateKeyHex = "de6e182c9456edeb1148387dadc8f981905377279feb9547d095152ef0f569d9"
    static let privateKeyBase64 = "3m4YLJRW7esRSDh9rcj5gZBTdyef65VH0JUVLvD1adk="
    static let privateKeyData = Data(hex: MockEthereumWalletTestData.privateKeyHex)

    static let privateKey = EthereumPrivateKey(
        mnemonic: MockEthereumWalletTestData.mnemonic,
        data: MockEthereumWalletTestData.privateKeyData
    )
    static let keyPair = EthereumKeyPair(
        address: MockEthereumWalletTestData.account,
        publicKey: MockEthereumWalletTestData.publicKeyHex,
        privateKey: MockEthereumWalletTestData.privateKey
    )

    enum Transaction {
        static let to = "0x3535353535353535353535353535353535353535"
        static let value: BigUInt = 1
        static let nonce: BigUInt = 9
        static let chainID: BigUInt = 1
        static let gasPrice: BigUInt = 11000000000
        static let gasLimit: BigUInt = 21000
        static let gasLimitContract: BigUInt = 65000
        static let data: Data? = Data()
    }
}

extension EthereumTransactionCandidate {
    static var defaultMock: EthereumTransactionCandidate {
        EthereumTransactionCandidate(
            to: EthereumAddress(address: MockEthereumWalletTestData.Transaction.to, network: .ethereum)!,
            gasPrice: MockEthereumWalletTestData.Transaction.gasPrice,
            gasLimit: MockEthereumWalletTestData.Transaction.gasLimit,
            value: MockEthereumWalletTestData.Transaction.value,
            nonce: MockEthereumWalletTestData.Transaction.nonce,
            chainID: MockEthereumWalletTestData.Transaction.chainID,
            transferType: .transfer()
        )
    }
}

extension EthereumWalletAccount {
    static var defaultMock: EthereumWalletAccount {
        EthereumWalletAccount(
            index: 0,
            publicKey: MockEthereumWalletTestData.account,
            label: "",
            archived: false
        )
    }
}
