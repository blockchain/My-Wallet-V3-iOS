// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import FeatureDashboardDomain
import Foundation
import SwiftUI

public enum PresentedAssetType: Decodable {
    case custodial
    case nonCustodial

    var assetDisplayLimit: Int {
        7
    }

    var isCustodial: Bool {
        self == .custodial
    }

    var rowType: PresentedAssetRowType {
        switch self {
        case .custodial:
            return .custodial
        case .nonCustodial:
            return .nonCustodial
        }
    }
}

public enum PresentedAssetRowType: Decodable {
    case custodial
    case nonCustodial
    case fiat

    var isCustodial: Bool {
        self == .custodial
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

        var type: PresentedAssetRowType
        var asset: AssetBalanceInfo
        var isLastRow: Bool

        var trailingTitle: String {
            switch type {
            case .custodial,
                 .nonCustodial:
                return asset.fiatBalance?.quote.toDisplayString(includeSymbol: true) ?? ""
            case .fiat:
                return asset.fiatBalance?.quote.toDisplayString(includeSymbol: true) ?? ""
            }
        }

        var trailingDescriptionString: String? {
            switch type {
            case .custodial:
                return asset.priceChangeString
            case .nonCustodial:
                return asset.balance.toDisplayString(includeSymbol: true)
            case .fiat:
                guard showsQuoteBalance else {
                    return nil
                }
                return asset.balance.toDisplayString(includeSymbol: true)
            }
        }

        var showsQuoteBalance: Bool {
            asset.fiatBalance?.quote.currency != asset.balance.currency
        }

        var trailingDescriptionColor: Color? {
            type.isCustodial ? asset.priceChangeColor : nil
        }

        var trailingIcon: (Icon, Color)? {
            guard type != .fiat else { return nil }

            if let delta = asset.delta, delta.isSignMinus == false, delta >= 4 {
                return (Icon.fireFilled, Color.semantic.warningMuted)

            }
            return nil
        }

        public init(
            type: PresentedAssetRowType,
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
                return .fireAndForget { [assetInfo = state.asset] in
                    app.post(
                        action: blockchain.ux.dashboard.asset[assetInfo.currency.code].paragraph.row.tap.then.enter.into,
                        value: blockchain.ux.asset[assetInfo.currency.code]
                    )
                }
            }
        }
    }
}
