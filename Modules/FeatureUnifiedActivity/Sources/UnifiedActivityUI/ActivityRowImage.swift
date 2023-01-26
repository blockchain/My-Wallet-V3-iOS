// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI
import UnifiedActivityDomain

@available(iOS 15, *)
public struct ActivityRowImage: View {

    let image: ImageType?

    public init(image: ImageType?) {
        self.image = image
    }

    public var body: some View {
        switch image {
        case .smallTag(let model):
            ZStack(alignment: .bottomTrailing) {
                AsyncMedia(url: URL(string: model.main ?? ""), placeholder: { EmptyView() })
                    .frame(width: 25, height: 25)
                    .background(Color.WalletSemantic.light, in: Circle())

                if model.hasTagImage {
                    ZStack(alignment: .center) {
                        AsyncMedia(url: URL(string: model.tag ?? ""), placeholder: { EmptyView() })
                            .frame(width: 12, height: 12)
                            .background(Color.WalletSemantic.background, in: Circle())
                        Circle()
                            .strokeBorder(Color.WalletSemantic.background, lineWidth: 1)
                            .frame(width: 13, height: 13)
                    }
                }
            }
        case .singleIcon(let model):
            AsyncMedia(url: URL(string: model.url ?? ""), placeholder: { EmptyView() })
                .frame(width: 25, height: 25)
                .background(Color.WalletSemantic.light, in: Circle())
        case .overlappingPair(let model):
            ZStack(alignment: .bottomTrailing) {
                ZStack(alignment: .center) {
                    AsyncMedia(url: URL(string: model.back ?? ""), placeholder: { EmptyView() })
                        .background(
                            Color.WalletSemantic.light,
                            in: Circle()
                        )
                        .frame(width: 18, height: 18)
                    Circle()
                        .strokeBorder(Color.WalletSemantic.background, lineWidth: 1)
                        .frame(width: 19, height: 19)
                }
                .padding(.bottom, 8)
                .padding(.trailing, 4)
                .zIndex(1)
                AsyncMedia(url: URL(string: model.front ?? ""), placeholder: { EmptyView() })
                    .frame(width: 18, height: 18)
                    .background(Color.WalletSemantic.light, in: Circle())
            }
        case nil:
            EmptyView()
        }
    }
}

// MARK: SwiftUI Preview

@available(iOS 16, *)
struct ActivityRowImage_Previews: PreviewProvider {

    static let receiveLogo = "https://login.blockchain.com/static/asset/icon/receive.svg"
    static let polygonLogo = "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/polygon/info/logo.png"
    static let usdcLogo = "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/polygon/assets/0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174/logo.png"
    static let btcLogo = "https://raw.githubusercontent.com/blockchain/coin-definitions/master/extensions/blockchains/bitcoin/info/logo.png"

    static var previews: some View {

        NavigationStack {
            Group {
                Text("SmallTag")
                    .padding()
                ActivityRowImage(
                    image: .smallTag(
                        .init(
                            main: Self.polygonLogo,
                            tag: Self.receiveLogo
                        )
                    )
                )

                Text("SingleIcon")
                    .padding()
                ActivityRowImage(
                    image: .singleIcon(
                        .init(url: Self.polygonLogo)
                    )
                )

                Text("OverlappingPair")
                    .padding()
                ActivityRowImage(
                    image: .overlappingPair(
                        .init(
                            back: Self.btcLogo,
                            front: Self.usdcLogo
                        )
                    )
                )

                Text("Nil")
                    .padding()
                ActivityRowImage(
                    image: nil
                )
            }
        }
    }
}
