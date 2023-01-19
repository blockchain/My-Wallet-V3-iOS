// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import ToolKit

public final class BitPayInvoiceTarget: CryptoReceiveAddress, StaticTransactionTarget {

    // MARK: - Public Properties

    public let asset: CryptoCurrency
    public let address: String
    public let amount: CryptoValue
    public let invoiceId: String
    public let merchant: String
    public var label: String {
        "BitPay\(merchant)"
    }
    public var assetName: String = ""

    public var accountType: AccountType = .external

    public var currencyType: CurrencyType {
        amount.currencyType
    }

    public var expirationTimeInSeconds: TimeInterval {
        guard let expiryDate = DateFormatter.utcSessionDateFormat.date(from: expires) else {
            fatalError("Expected a date: \(expires)")
        }
        guard let seconds = Calendar.current.dateComponents([.second], from: Date(), to: expiryDate).second,
              seconds >= 0
        else {
            return 0
        }
        return TimeInterval(seconds)
    }

    // MARK: - Private Properties

    private let expires: String

    // MARK: - Init

    public init(
        asset: CryptoCurrency,
        amount: CryptoValue,
        invoiceId: String,
        merchant: String,
        address: String,
        expires: String
    ) {
        self.asset = asset
        self.amount = amount
        self.invoiceId = invoiceId
        self.merchant = merchant
        self.address = address
        self.expires = expires
    }
}
