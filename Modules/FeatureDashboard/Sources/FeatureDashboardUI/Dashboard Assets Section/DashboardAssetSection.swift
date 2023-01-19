// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import ComposableArchitecture
import ComposableArchitectureExtensions
import DIKit
import FeatureDashboardDomain
import FeatureWithdrawalLocksDomain
import Foundation
import MoneyKit
import PlatformKit
import SwiftUI
import ToolKit

public struct DashboardAssetsSection: ReducerProtocol {
    public let assetBalanceInfoRepository: AssetBalanceInfoRepositoryAPI
    public let withdrawalLocksRepository: WithdrawalLocksRepositoryAPI
    public let app: AppProtocol
    public init(
        assetBalanceInfoRepository: AssetBalanceInfoRepositoryAPI,
        withdrawalLocksRepository: WithdrawalLocksRepositoryAPI,
        app: AppProtocol
    ) {
        self.assetBalanceInfoRepository = assetBalanceInfoRepository
        self.withdrawalLocksRepository = withdrawalLocksRepository
        self.app = app
    }

    public enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case onBalancesFetched(Result<[AssetBalanceInfo], Never>)
        case onFiatBalanceFetched(Result<[AssetBalanceInfo], Never>)
        case onWithdrawalLocksFetched(Result<WithdrawalLocks, Never>)
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
        var withdrawalLocks: WithdrawalLocks?

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

                let cryptoEffect = app.publisher(for: blockchain.user.currency.preferred.fiat.display.currency, as: FiatCurrency.self)
                    .compactMap(\.value)
                    .flatMap { [state] fiatCurrency -> StreamOf<[AssetBalanceInfo], Never> in
                        let cryptoPublisher = state.presentedAssetsType.isCustodial
                        ? self.assetBalanceInfoRepository.cryptoCustodial(fiatCurrency: fiatCurrency, time: .now)
                        : self.assetBalanceInfoRepository.cryptoNonCustodial(fiatCurrency: fiatCurrency, time: .now)
                        return cryptoPublisher
                    }
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect()
                    .map(Action.onBalancesFetched)

                let fiatEffect = app.publisher(for: blockchain.user.currency.preferred.fiat.display.currency, as: FiatCurrency.self)
                    .compactMap(\.value)
                    .flatMap { fiatCurrency -> StreamOf<[AssetBalanceInfo], Never> in
                        self.assetBalanceInfoRepository
                            .fiat(fiatCurrency: fiatCurrency, time: .now)
                    }
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect()
                    .map(Action.onFiatBalanceFetched)

                let onHoldEffect = app.publisher(
                        for: blockchain.user.currency.preferred.fiat.display.currency,
                        as: FiatCurrency.self
                    )
                    .compactMap(\.value)
                    .flatMap { fiatCurrency -> StreamOf<WithdrawalLocks, Never> in
                        self.withdrawalLocksRepository
                            .withdrawalLocks(currencyCode: fiatCurrency.code)
                            .result()
                    }
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect()
                    .map(Action.onWithdrawalLocksFetched)

                return .merge(
                    cryptoEffect,
                    fiatEffect,
                    onHoldEffect
                )

            case .onBalancesFetched(.success(let balanceInfo)):
                state.isLoading = false
                state.seeAllButtonHidden = balanceInfo
                    .filter(\.balance.hasPositiveDisplayableBalance)
                    .count <= state.presentedAssetsType.assetDisplayLimit

                let maxDisplayableRows = state.presentedAssetsType.assetDisplayLimit
                let balanceInfoFiltered = state.presentedAssetsType.isCustodial ? balanceInfo.filter(\.hasBalance) : balanceInfo
                let elements = Array(balanceInfoFiltered)
                    .prefix(state.presentedAssetsType.assetDisplayLimit)
                    .enumerated()
                    .map { (offset, element) in
                        DashboardAssetRow.State(
                            type: state.presentedAssetsType.rowType,
                            isLastRow: offset == maxDisplayableRows - 1,
                            asset: element
                        )
                    }
                state.assetRows = IdentifiedArrayOf(uniqueElements: elements)
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

            case .onWithdrawalLocksFetched(.success(let withdrawalLocks)):
                state.withdrawalLocks = withdrawalLocks
                return .none

            case .onWithdrawalLocksFetched(.failure):
                return .none

            case .assetRowTapped:
                return .none

            case .onAllAssetsTapped:
                return .none

            case .fiatAssetRowTapped:
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
