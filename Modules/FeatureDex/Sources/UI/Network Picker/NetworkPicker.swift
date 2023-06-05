//Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ComposableArchitecture
import MoneyKit
import FeatureDexDomain

public struct NetworkPicker: ReducerProtocol {
    public struct State: Equatable {
        var availableChains: [Chain] = []
        var selectedNetwork: Chain?
        var logo: CryptoCurrency? {
            if let selectedNetwork {
                return CryptoCurrency(code: selectedNetwork.nativeCurrency.symbol)
            }
            return nil
        }
    }

    public enum Action: Equatable {
        case onNetworkSelected(Chain)
        case onDismiss
    }

    public var body: some ReducerProtocol<State,Action> {
        Reduce { state, action in
            switch action {
            case .onNetworkSelected:
                return .none
            case .onDismiss:
                return .none
            }
        }
    }
}
