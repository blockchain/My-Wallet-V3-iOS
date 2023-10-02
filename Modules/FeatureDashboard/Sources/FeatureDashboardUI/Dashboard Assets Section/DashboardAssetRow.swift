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

    var smallBalanceFilterTag: Tag.Event {
        switch self {
        case .custodial:
            return blockchain.ux.dashboard.trading.assets.small.balance.filtering.is.on
        case .nonCustodial:
            return blockchain.ux.dashboard.defi.assets.small.balance.filtering.is.on
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

    public init(app: AppProtocol) {
        self.app = app
    }

    public enum Action: Equatable {}

    public struct State: Equatable, Identifiable {
        public var id: String { asset.id }

        var type: PresentedAssetRowType
        var asset: AssetBalanceInfo
        var isLastRow: Bool

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
        EmptyReducer()
    }
}
