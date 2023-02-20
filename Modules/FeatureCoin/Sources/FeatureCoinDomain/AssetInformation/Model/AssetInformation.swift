// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

public struct AssetInformation: Hashable {

    public let description: String?
    public let whitepaper: URL?
    public let website: URL?

    public var isEmpty: Bool {
        description.isNilOrEmpty && website.isNil
    }

    public init(
        description: String?,
        whitepaper: String?,
        website: String?
    ) {
        self.description = description
        self.whitepaper = whitepaper.flatMap(URL.init(string:))
        self.website = website.flatMap(URL.init(string:))
    }
}

extension AssetInformation {

    public static var preview: AssetInformation {
        AssetInformation(
            description: "Bitcoin uses peer-to-peer technology to operate with no central authority or banks; managing transactions and the issuing of bitcoins is carried out collectively by the network. Although other cryptocurrencies have come before, Bitcoin is the first decentralized cryptocurrency - Its reputation has spawned copies and evolution in the space.With the largest variety of markets and the biggest value - having reached a peak of 318 billion USD - Bitcoin is here to stay.",
            whitepaper: "https://www.cryptocompare.com/media/37745820/bitcoin.pdf",
            website: "https://bitcoin.org"
        )
    }
}
