// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct StellarAssetAccount: Equatable {

    let address: StellarAssetAddress
    let accountAddress: String
    let name: String
    let description: String
    let sequence: Int
    let subentryCount: UInt
    let walletIndex: Int

    init(
        accountAddress: String,
        name: String,
        description: String,
        sequence: Int,
        subentryCount: UInt
    ) {
        self.walletIndex = 0
        self.accountAddress = accountAddress
        self.name = name
        self.description = description
        self.sequence = sequence
        self.subentryCount = subentryCount
        self.address = StellarAssetAddress(publicKey: accountAddress)
    }
}
