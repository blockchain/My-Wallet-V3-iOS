// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

public struct AboutAssetInformation: Hashable {

    public let description: String?
    public let whitepaper: URL?
    public let website: URL?
    public let network: String?
    public let marketCap: FiatValue?
    public let contractAddress: String?
    public let isEmpty: Bool

    public init(
        description: String?,
        whitepaper: URL?,
        website: URL?,
        network: String?,
        marketCap: FiatValue?,
        contractAddress: String?
    ) {
        self.description = description
        self.whitepaper = whitepaper
        self.website = website
        self.network = network
        self.marketCap = marketCap
        self.contractAddress = contractAddress
        self.isEmpty = description == nil
            && whitepaper == nil
            && website == nil
            && network == nil
            && marketCap == nil
            && contractAddress == nil
    }
}
