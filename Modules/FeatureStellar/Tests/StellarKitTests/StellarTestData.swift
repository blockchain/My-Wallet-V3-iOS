// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

enum StellarTestData {

    // MARK: Base

    static let address = "GBIRQUDJO7JT4FIG53BD22DJ4BYO7R5ERHWQMXRLDDF7UZUJQYWQPDOM"
    static let memo = "memo-memo"
    static let label = "account-label"

    // MARK: Address Memo

    static let addressColonMemo = "\(address):\(memo)"

    // MARK: URL

    static let urlString = "web+stellar:pay?destination=\(address)"
    static let urlStringWithMemo = "web+stellar:pay?destination=\(address)&memo=\(memo)"
    static let urlStringWithMemoType = "web+stellar:pay?destination=\(address)&memo=\(memo)&memo_type=MEMO_TEXT"
    static let urlStringWithMemoAndAmount = "web+stellar:pay?destination=\(address)&amount=123456&memo=\(memo)"
}
