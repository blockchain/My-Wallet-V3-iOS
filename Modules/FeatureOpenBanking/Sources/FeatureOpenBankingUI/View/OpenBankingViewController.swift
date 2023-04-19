// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import FeatureOpenBankingDomain
import SwiftUI
import UIComponentsKit

public final class OpenBankingViewController: UIHostingController<OpenBankingViewController.Container> {

    public var bag: Set<AnyCancellable> = []
    public var eventPublisher: AnyPublisher<Result<Void, OpenBanking.Error>, Never>

    public convenience init(
        order: OpenBanking.Order,
        from account: OpenBanking.BankAccount,
        environment: OpenBankingEnvironment
    ) {
        self.init(
            .confirm(
                order: order,
                from: account
            ),
            environment: environment
        )
    }

    public convenience init(
        deposit amountMinor: String,
        product: String,
        from account: OpenBanking.BankAccount,
        environment: OpenBankingEnvironment
    ) {
        self.init(
            .deposit(
                amountMinor: amountMinor,
                product: product,
                from: account
            ),
            environment: environment
        )
    }

    public convenience init(account: OpenBanking.BankAccount, environment: OpenBankingEnvironment) {
        self.init(.linkBankAccount(account), environment: environment)
    }

    public struct Container: View {

        let store: Store<OpenBankingState, OpenBankingAction>
        let environment: OpenBankingEnvironment

        public var body: some View {
            OpenBankingView(store: store)
                .app(environment.app)
        }
    }

    required init(_ state: OpenBankingState, environment: OpenBankingEnvironment) {
        self.eventPublisher = environment.eventPublisher.eraseToAnyPublisher()
        let store = Store<OpenBankingState, OpenBankingAction>(
            initialState: state,
            reducer: openBankingReducer,
            environment: environment
        )
        super.init(
            rootView: Container(store: store, environment: environment)
        )
    }

    @objc dynamic required init?(coder aDecoder: NSCoder) {
        unimplemented()
    }
}
