// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import BlockchainUI
import ComposableArchitecture
import FeatureDexDomain
import MoneyKit
import SwiftUI

extension AssetPickerView {

    public struct Cell: View {

        let data: AssetPicker.RowData
        @State var price: FiatValue?
        @State var delta: Decimal?
        let action: () -> Void

        @ViewBuilder
        public var body: some View {
            switch data.content {
            case .balance(let balance):
                balance.value.moneyValue
                    .rowView(
                        .quote,
                        byline: { MoneyValueCodeNetworkView(balance.value.currencyType) }
                    )
            case .token(let token):
                MoneyValue
                    .one(currency: .crypto(token))
                    .rowView(.delta)
            }
        }
    }
}

struct AssetPickerView_Cell_Previews: PreviewProvider {

    private static var app = App.preview.withPreviewData()

    private static var usdt: CryptoCurrency! {
        _ = app
        return EnabledCurrenciesService.default
            .allEnabledCryptoCurrencies
            .first(where: { $0.code == "USDT" })
    }

    private static var currencies: [CryptoCurrency] {
        [usdt, .bitcoin, .ethereum]
    }

    static var balances: [AssetPicker.RowData] = currencies
        .map { CryptoValue.create(major: Decimal(2), currency: $0) }
        .map(DexBalance.init(value:))
        .map(AssetPicker.RowData.Content.balance)
        .map(AssetPicker.RowData.init(content:))

    static var tokens: [AssetPicker.RowData] = currencies
        .map(AssetPicker.RowData.Content.token)
        .map(AssetPicker.RowData.init(content:))

    private static var dataSource: [AssetPicker.RowData] = balances + tokens
    
    static var previews: some View {
        ScrollView {
            ForEach(dataSource) { data in
                AssetPickerView.Cell(
                    data: data,
                    action: { print(data) }
                )
                .app(app)
            }
        }
        .padding(.horizontal, Spacing.padding2)
        .background(Color.semantic.light.ignoresSafeArea())
    }
}
