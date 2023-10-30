import Blockchain
import ComposableArchitecture
import SwiftUI

@MainActor
public struct SiteMap {

    let app: AppProtocol

    public init(app: AppProtocol) {
        self.app = app
    }

    @ViewBuilder public func view(
        for ref: Tag.Reference,
        in context: Tag.Context = [:]
    ) throws -> some View {
        switch ref {
        case blockchain.ux.currency.exchange.dex.no.balance.sheet:
            let networkTicker = try context[blockchain.ux.currency.exchange.dex.no.balance.sheet.network]
                .decode(String.self)
            DexNoBalanceView(networkTicker: networkTicker)

        case blockchain.ux.currency.exchange.router:
            SwapProductRouterView()

        case blockchain.ux.currency.exchange.dex.allowance.sheet:
            let cryptoCurrency = try context[blockchain.ux.currency.exchange.dex.allowance.sheet.currency].decode(CryptoCurrency.self)
            let allowanceSpender = try context[blockchain.ux.currency.exchange.dex.allowance.sheet.allowance.spender].decode(String.self)
            DexAllowanceView(cryptoCurrency: cryptoCurrency, allowanceSpender: allowanceSpender)

        default:
            throw "Unknown View of \(ref) in \(Self.self)"
        }
    }
}
