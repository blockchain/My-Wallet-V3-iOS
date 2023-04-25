// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

public protocol ReceiveAddress: TransactionTarget {
    var address: String { get }
    var memo: String? { get }
    var predefinedAmount: MoneyValue? { get }
}

extension ReceiveAddress {
    public var memo: String? {
        nil
    }

    public var predefinedAmount: MoneyValue? {
        nil
    }
}

public protocol CryptoReceiveAddress: ReceiveAddress, CryptoTarget {}

extension CryptoReceiveAddress {

    public var accountType: AccountType {
        .external
    }
}

public protocol QRCodeMetadataProvider {
    var qrCodeMetadata: QRCodeMetadata { get }
}

public enum ReceiveAddressError: Error {
    case notSupported
}
