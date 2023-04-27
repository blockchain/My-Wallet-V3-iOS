import BlockchainUI
import SwiftUI

public struct DexConfirmation: ReducerProtocol {

    let app: AppProtocol

    public struct State: Hashable {

        public struct Target: Hashable {
            public var value: CryptoValue
            public var toFiatExchangeRate: MoneyValue?
            public var currency: CryptoCurrency { value.currency }
        }

        @BindingState public var from: Target
        @BindingState public var to: Target

        public var exchangeRate: MoneyValuePair {
            MoneyValuePair(base: from.value.moneyValue, quote: to.value.moneyValue).exchangeRate
        }

        public struct Fee: Hashable {
            public var network, blockchain: CryptoValue
        }

        public var slippage: Double
        public var minimumReceivedAmount: CryptoValue
        public var fee: Fee

        public var priceUpdated: Bool = false
        public var enoughBalance: Bool = true
    }

    public enum Action: BindableAction {
        case confirm
        case acceptPrice
        case binding(BindingAction<State>)
    }

    public init(app: AppProtocol) {
        self.app = app
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .acceptPrice:
                state.priceUpdated = false
            case .binding, .confirm: break
            }
            return .none
        }
    }
}

extension DexConfirmation.State {

    static var preview: Self = .init(
        from: .init(value: .create(major: 0.05, currency: .ethereum)),
        to: .init(value: .create(major: 62.23, currency: .usdt)),
        slippage: 0.0013,
        minimumReceivedAmount: CryptoValue.create(major: 61.92, currency: .usdt),
        fee: .init(
            network: .create(major: 0.005, currency: .ethereum),
            blockchain: .create(major: 1.2, currency: .usdt)
        )
    )

    mutating func setup(_ body: (inout Self) -> Void) -> Self {
        var copy = self
        body(&copy)
        return copy
    }
}
