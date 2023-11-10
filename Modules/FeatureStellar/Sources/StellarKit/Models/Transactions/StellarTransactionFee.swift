// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit

struct StellarTransactionFee {

    static let `default` = StellarTransactionFee(
        regular: 1000,
        priority: 10000
    )

    let regular: CryptoValue
    let priority: CryptoValue

    init(regular: Int, priority: Int) {
        self.regular = CryptoValue.create(
            minor: regular,
            currency: .stellar
        )
        self.priority = CryptoValue.create(
            minor: priority,
            currency: .stellar
        )
    }
}
