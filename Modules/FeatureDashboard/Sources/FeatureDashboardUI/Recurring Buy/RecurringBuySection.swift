// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainUI
import DIKit
import FeatureCoinDomain
import FeatureCoinUI
import FeatureTransactionDomain
import SwiftUI

public struct RecurringBuySection: View {

    @BlockchainApp var app

    @StateObject var model = Model()

    public init() {}

    public var body: some View {
        RecurringBuyListView(
            buys: model.displayableBuys,
            location: .dashboard(asset: CryptoCurrency.bitcoin.code),
            showsManageButton: $model.showsManageButton
        )
        .onAppear {
            model.prepare(app)
        }
    }
}

extension RecurringBuySection {

    class Model: ObservableObject {
        typealias BuyItem = FeatureCoinDomain.RecurringBuy

        @Published var buys: [BuyItem]?
        @Published var showsManageButton: Bool = false

        /// A maximum of five (5) recurring buys to be displayed on dashboard
        var displayableBuys: [BuyItem]? {
            guard let buys else {
                return nil
            }
            return Array(buys.prefix(5))
        }

        private let repository: RecurringBuyProviderRepositoryAPI

        init(repository: RecurringBuyProviderRepositoryAPI = resolve()) {
            self.repository = repository
        }

        func prepare(_ app: AppProtocol) {

            app.on(blockchain.ux.home.event.did.pull.to.refresh, blockchain.ux.transaction.event.execution.status.completed)
                .mapToVoid()
                .prepend(())
                .flatMap { [repository] _ -> AnyPublisher<[FeatureTransactionDomain.RecurringBuy], NabuNetworkError> in
                    repository.fetchRecurringBuys()
                        .eraseToAnyPublisher()
                }
                .map { (buys: [FeatureTransactionDomain.RecurringBuy]) in buys.map(BuyItem.init) }
                .handleEvents(receiveOutput: { items in
                    // in case there's no RC active we show the onboarding flow
                    if let items {
                        app.state.set(blockchain.ux.recurring.buy.onboarding.has.active.buys, to: items.isNotEmpty)
                    } else {
                        app.state.set(blockchain.ux.recurring.buy.onboarding.has.active.buys, to: false)
                    }
                })
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
                .assign(to: &$buys)

            $buys
                .replaceNil(with: [])
                .map { items in
                    items.count >= 1
                }
                .assign(to: &$showsManageButton)
        }
    }
}

// MARK: Internal Extensions

extension FeatureCoinDomain.RecurringBuy {
    init(_ recurringBuy: FeatureTransactionDomain.RecurringBuy) {
        self.init(
            id: recurringBuy.id,
            recurringBuyFrequency: recurringBuy.recurringBuyFrequency.description,
            nextPaymentDate: recurringBuy.nextPaymentDate,
            paymentMethodType: recurringBuy.paymentMethodTypeDescription,
            amount: recurringBuy.amount.displayString,
            asset: recurringBuy.asset.displayCode
        )
    }
}

extension FeatureTransactionDomain.RecurringBuy {
    private typealias L01n = LocalizationConstants.Transaction.Buy.Recurring.PaymentMethod
    fileprivate var paymentMethodTypeDescription: String {
        switch paymentMethodType {
        case .bankTransfer,
                .bankAccount:
            return L01n.bankTransfer
        case .card:
            return L01n.creditOrDebitCard
        case .applePay:
            return L01n.applePay
        case .funds:
            return amount.currency.name + " \(L01n.account)"
        }
    }
}
