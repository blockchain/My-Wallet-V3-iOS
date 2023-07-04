import Blockchain
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
            ProductRouterView()

        case blockchain.ux.currency.exchange.dex.settings.sheet:
            let slippage = try context[blockchain.ux.currency.exchange.dex.settings.sheet.slippage].decode(Double.self)
            DexSettingsView(slippage: slippage)

        case blockchain.ux.currency.exchange.dex.network.picker.sheet:
            let selectedNetworkTicker = try context[blockchain.ux.currency.exchange.dex.network.picker.sheet.selected.network].decode(String.self)
            NetworkPickerView(store: .init(initialState: .init(currentNetwork: selectedNetworkTicker),
                                           reducer: NetworkPicker()))

        case blockchain.ux.currency.exchange.dex.allowance.sheet:
            let cryptocurrency = try context[blockchain.ux.currency.exchange.dex.allowance.sheet.currency].decode(CryptoCurrency.self)
            DexAllowanceView(cryptoCurrency: cryptocurrency)

        default:
            throw "Unknown View of \(ref) in \(Self.self)"
        }
    }
}
