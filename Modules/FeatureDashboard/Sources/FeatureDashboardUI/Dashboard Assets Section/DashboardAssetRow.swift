// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import FeatureDashboardDomain
import Foundation
import SwiftUI

public enum PresentedAssetType: Decodable {
    case custodial
    case nonCustodial
    case fiat

    var assetDisplayLimit: Int {
        self == .custodial ? 8 : 5
    }
}

public struct DashboardAssetRow: ReducerProtocol {
    public let app: AppProtocol
    public init(
        app: AppProtocol
    ) {
        self.app = app
    }

    public enum Action: Equatable {
        case onAssetTapped
    }

    public struct State: Equatable, Identifiable {
        public var id: String {
            asset.id
        }

        var type: PresentedAssetType
        var asset: AssetBalanceInfo
        var isLastRow: Bool

        var trailingDescriptionString: String {
            switch type {
            case .custodial:
                return asset.priceChangeString ?? ""
            case .nonCustodial:
                return asset.cryptoBalance.toDisplayString(includeSymbol: true)
            case .fiat:
                return asset.cryptoBalance.toDisplayString(includeSymbol: true)
            }
        }

        var trailingDescriptionColor: Color? {
            type == .custodial ? asset.priceChangeColor : nil
        }

        public init(
            type: PresentedAssetType,
            isLastRow: Bool,
            asset: AssetBalanceInfo
        ) {
            self.type = type
            self.asset = asset
            self.isLastRow = isLastRow
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAssetTapped:
                print(state.asset)
                return .fireAndForget { [assetInfo = state.asset] in
                    print(assetInfo)
                    app.post(
                        action: blockchain.ux.asset.select.then.enter.into,
                        value: blockchain.ux.asset[assetInfo.currency.code],
                        context: [blockchain.ux.asset.select.origin: "ASSETS"]
                    )
                }
            }
        }
    }
}
