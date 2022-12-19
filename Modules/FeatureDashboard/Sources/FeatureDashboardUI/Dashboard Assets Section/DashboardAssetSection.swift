// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import ComposableArchitectureExtensions
import DIKit
import FeatureDashboardDomain
import Foundation
import MoneyKit
import PlatformKit
import SwiftUI

public struct DashboardAssetsSection: ReducerProtocol {
    public let assetBalanceInfoRepository: AssetBalanceInfoRepositoryAPI
    public let app: AppProtocol
    public init(
        assetBalanceInfoRepository: AssetBalanceInfoRepositoryAPI,
        app: AppProtocol
    ) {
        self.assetBalanceInfoRepository = assetBalanceInfoRepository
        self.app = app
    }

    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case onBalancesFetched(Result<[AssetBalanceInfo], Never>)
        case onFiatBalanceFetched(Result<[AssetBalanceInfo], Never>)
        case onAllAssetsTapped
        case assetRowTapped(
            id: DashboardAssetRow.State.ID,
            action: DashboardAssetRow.Action
        )

        case fiatAssetRowTapped(
            id: DashboardAssetRow.State.ID,
            action: DashboardAssetRow.Action
        )
        case onWalletAction(action: WalletActionSheet.Action)
    }

    public struct State: Equatable {
        @BindableState var isWalletActionSheetShown = false
        var isLoading: Bool = false
        var fiatAssetInfo: [AssetBalanceInfo] = []
        let presentedAssetsType: PresentedAssetType
        var assetRows: IdentifiedArrayOf<DashboardAssetRow.State> = []
        var fiatAssetRows: IdentifiedArrayOf<DashboardAssetRow.State> = []
        var walletSheetState: WalletActionSheet.State?

        var seeAllButtonHidden = true
        public init(presentedAssetsType: PresentedAssetType) {
            self.presentedAssetsType = presentedAssetsType
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true

                let cryptoPublisher = state.presentedAssetsType == .custodial ? self.assetBalanceInfoRepository.cryptoCustodial() :
                self.assetBalanceInfoRepository.cryptoNonCustodial()

                let cryptoEffect = cryptoPublisher
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect()
                    .map(Action.onBalancesFetched)

                let fiatEffect = self.assetBalanceInfoRepository
                    .fiat()
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect()
                    .map(Action.onFiatBalanceFetched)

                return .merge(
                    cryptoEffect,
                    fiatEffect
                )

            case .onBalancesFetched(.success(let balanceInfo)):
                state.isLoading = false
                state.seeAllButtonHidden = balanceInfo
                    .filter(\.cryptoBalance.hasPositiveDisplayableBalance)
                    .count <= state.presentedAssetsType.assetDisplayLimit

                if state.presentedAssetsType == .custodial {
                    state.assetRows = IdentifiedArrayOf(uniqueElements: Array(balanceInfo.filter(\.hasBalance)
                        .prefix(state.presentedAssetsType.assetDisplayLimit))
                        .map {
                            DashboardAssetRow.State(
                                type: state.presentedAssetsType,
                                isLastRow: $0.id == balanceInfo.last?.id,
                                asset: $0
                            )
                        }
                    )
                } else {
                    state.assetRows = IdentifiedArrayOf(uniqueElements: Array(balanceInfo
                        .prefix(state.presentedAssetsType.assetDisplayLimit))
                        .map {
                            DashboardAssetRow.State(
                                type: state.presentedAssetsType,
                                isLastRow: $0.id == balanceInfo.last?.id,
                                asset: $0
                            )
                        }
                    )
                }
                return .none

            case .onBalancesFetched(.failure):
                state.isLoading = false
                return .none

            case .onFiatBalanceFetched(.success(let fiatBalance)):
                state.fiatAssetRows = IdentifiedArrayOf(uniqueElements: Array(fiatBalance).map {
                    DashboardAssetRow.State(
                        type: .fiat,
                        isLastRow: $0.id == fiatBalance.last?.id,
                        asset: $0
                    )
                })

                return .none
            case .onFiatBalanceFetched(.failure):
                return .none

            case .assetRowTapped:
                return .none

            case .onAllAssetsTapped:
                return .none

            case .fiatAssetRowTapped(let id, _):
//                if let fiatAssetRow = state.fiatAssetRows.filter({$0.id == id}).first {
//                    app.post(
//                        event: blockchain.ux.multiapp.wallet.action.sheet,
//                        context: [blockchain.ux.asset.balanceInfo: fiatAssetRow.asset]
//                    )
//                }
                return .none

            case .binding:
                return .none

            case .onWalletAction:
                return .none
            }
        }
        .forEach(\.assetRows, action: /Action.assetRowTapped) {
            DashboardAssetRow(app: self.app)
        }
        .forEach(\.fiatAssetRows, action: /Action.fiatAssetRowTapped) {
            DashboardAssetRow(app: self.app)
        }
    }
}
