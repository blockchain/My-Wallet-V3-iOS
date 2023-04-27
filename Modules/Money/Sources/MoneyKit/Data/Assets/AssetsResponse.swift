// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A supported assets endpoint response, representing a list of supported assets.
struct AssetsResponse: Codable {

    /// A supported asset.
    struct Asset: Codable {

        /// The asset code (e.g. `USD`, `BTC`, etc.). This should be used for API calls (instead of using `displaySymbol`).
        let symbol: String

        /// The asset display code (e.g. `USD`, `BTC`, etc.). This can be different to `symbol` (e.g. for some ERC-20 tokens), and should only be used for display purposes.
        let displaySymbol: String?

        /// The asset name (e.g. `US Dollar`, `Bitcoin`, etc.).
        let name: String

        /// The asset precision, representing the maximum number of decimal places.
        let precision: Int

        /// The list of supported asset products.
        let products: [String]

        /// The asset type.
        let type: AssetType

        /// A supported asset type.
        struct AssetType: Codable {

            /// An asset type name.
            enum Name: String {

                /// A coin asset.
                case coin = "COIN"

                /// An Ethereum ERC-20 asset.
                case erc20 = "ERC20"

                /// A fiat asset.
                case fiat = "FIAT"

                /// An Celo asset.
                case celoToken = "CELO_TOKEN"
            }

            /// The asset type name.
            let name: String

            /// The minimum number of on-chain confirmations, present on coin assets only.
            let minimumOnChainConfirmations: Int?

            /// The asset parent chain, present on Ethereum ERC-20 assets only.
            let parentChain: String?

            /// The ERC-20 contract address, prefixed by `0x`, prersent on Ehtereum ERC-20 assets only.
            let erc20Address: String?

            /// The URL to the asset logo.
            let logoPngUrl: String?

            /// The asset spot color.
            let spotColor: String?

            /// The URL to the asset website.
            let websiteUrl: String?
        }
    }

    /// The list of supported assets.
    let currencies: [Asset]
}
