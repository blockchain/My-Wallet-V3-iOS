// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableArchitectureExtensions
import Errors
import FeatureCoinDomain

public enum CoinViewAction: BlockchainNamespaceObservationAction, BindableAction {
    case onAppear
    case onDisappear
    case update(Result<(KYCStatus, [Account.Snapshot]), Error>)
    case fetchInterestRate
    case fetchedRecurringBuys(Result<[RecurringBuy], Error>)
    case fetchedInterestRate(Result<EarnRates, NetworkError>)
    case fetchedAssetInformation(Result<AssetInformation, NetworkError>)
    case refresh
    case reset
    case graph(GraphViewAction)
    case observation(BlockchainNamespaceObservation)
    case binding(BindingAction<CoinViewState>)
    case isOnWatchlist(Bool)
    case isRecurringBuyEnabled(Bool)
    case isDexEnabled(Bool)
    case addToWatchlist
    case removeFromWatchlist
    case dismiss
}
