// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import ComposableArchitecture
import Foundation

public struct SwapAccountRow: ReducerProtocol {
    public let app: AppProtocol
    public init(
        app: AppProtocol
    ) {
        self.app = app
    }

    public enum Action: Equatable, BindableAction {
        case onAppear
        case onAccountSelected
        case binding(BindingAction<SwapAccountRow.State>)
    }

    public struct State: Equatable, Identifiable {
        public var id: String {
            assetCode
        }

        var type: SwapAccountSelect.SelectionType
        var assetCode: String
        var isLastRow: Bool
        var appMode: AppMode?
        @BindingState var price: MoneyValue?
        @BindingState var delta: Decimal?
        @BindingState var balance: MoneyValue?
        @BindingState var networkLogo: URL?
        @BindingState var networkName: String?

        var currency: CryptoCurrency? {
            balance?.currency.cryptoCurrency
        }

        var leadingTitle: String {
            currency?.name ?? ""
        }

        var trailingTitle: String {
            price?.toDisplayString(includeSymbol: true) ?? ""
        }

        var trailingDescriptionString: String? {
            switch type {
            case .source:
                return balance?.toDisplayString(includeSymbol: true) ?? ""
            case .target:
                return priceChangeString
            }
        }

        var trailingDescriptionColor: Color? {
            switch type {
            case .source:
                return .semantic.text
            case .target:
                return priceChangeColor
            }
        }

        public init(
            type: SwapAccountSelect.SelectionType,
            isLastRow: Bool,
            assetCode: String
        ) {
            self.type = type
            self.isLastRow = isLastRow
            self.assetCode = assetCode
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.$price):
                return .none
            case .binding:
                return .none
            case .onAppear:
                state.appMode = app.currentMode
                return .none
            case .onAccountSelected:
                return .none
            }
        }
    }
}

extension SwapAccountRow.State {
    var priceChangeString: String? {
        guard let delta else {
            return nil
        }
        var arrowString: String {
            if delta.isZero {
                return ""
            }
            if delta.isSignMinus {
                return "↓"
            }

            return "↑"
        }
        if #available(iOS 15, *) {
            // delta value comes in range of 0...100, percent formatter needs to be in 0...1
            let deltaFormatted = delta.formatted(.percent.precision(.fractionLength(2)))
            return "\(arrowString) \(deltaFormatted)"
        } else {
            return "\(arrowString) \(delta) %"
        }
    }

    var priceChangeColor: Color? {
        guard let delta else {
            return nil
        }
        if delta.isZero {
            return Color.WalletSemantic.muted
        }
        return delta.isSignMinus ? Color.WalletSemantic.pinkHighlight : Color.WalletSemantic.success
    }

    var networkTag: TagView? {
        guard let networkName, networkName != currency?.name, appMode == .pkw else {
            return nil
        }
        return TagView(text: networkName, variant: .outline)
    }
}
