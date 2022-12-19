import BlockchainNamespace
import ComposableArchitecture
import FeatureDashboardDomain
import Foundation
import MoneyKit
import PlatformKit
import SwiftExtensions

public struct AllAssetsScene: ReducerProtocol {
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
        case onAppear
        case onBalancesFetched(Result<[AssetBalanceInfo], Never>)
        case binding(BindingAction<State>)
        case onFilterTapped
        case onConfirmFilterTapped
        case onResetTapped
        case onAssetTapped(AssetBalanceInfo)
        case onCloseTapped
    }

    public struct State: Equatable {
        var presentedAssetType: PresentedAssetType
        var balanceInfo: [AssetBalanceInfo]?
        @BindableState var searchText: String = ""
        @BindableState var isSearching: Bool = false
        @BindableState var filterPresented: Bool = false
        @BindableState var showSmallBalancesFilterIsOn: Bool = false

        var searchResults: [AssetBalanceInfo]? {
            guard let balanceInfo else {
                return nil
            }
            if searchText.isEmpty {
                return balanceInfo
                    .filtered(by: showSmallBalancesFilterIsOn)
            } else {
                return balanceInfo
                    .filtered(by: searchText)
                    .filtered(by: showSmallBalancesFilterIsOn)
            }
        }

        public init(with presentedAssetType: PresentedAssetType) {
            self.presentedAssetType = presentedAssetType
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                let publisher = state.presentedAssetType == .custodial ? self.assetBalanceInfoRepository.cryptoCustodial() :
                self.assetBalanceInfoRepository.cryptoNonCustodial()

                return publisher
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect()
                    .map(Action.onBalancesFetched)

            case .binding(\.$searchText):
                return .none

            case .binding(\.$isSearching):
                return .none

            case .onFilterTapped:
                state.filterPresented = true
                return .none

            case .onBalancesFetched(.success(let balanceinfo)):
                state.balanceInfo = balanceinfo.filter(\.cryptoBalance.hasPositiveDisplayableBalance)
                return .none

            case .onBalancesFetched(.failure):
                return .none

            case .onAssetTapped(let assetInfo):
                return .fireAndForget {
                    app.post(
                        action: blockchain.ux.asset.select.then.enter.into,
                        value: blockchain.ux.asset[assetInfo.currency.code],
                        context: [blockchain.ux.asset.select.origin: "ASSETS"]
                    )
                }

            case .onConfirmFilterTapped:
                state.filterPresented = false
                return .none

            case .onResetTapped:
                state.showSmallBalancesFilterIsOn = false
                return .none

            case .binding:
                return .none

            case .onCloseTapped:
                return .none
            }
        }
    }
}

extension [AssetBalanceInfo] {
    func filtered(by searchText: String, using algorithm: StringDistanceAlgorithm = FuzzyAlgorithm(caseInsensitive: true)) -> [Element] {
        filter {
            $0.currency.name.distance(between: searchText, using: algorithm) == 0 ||
            ($0.fiatBalance?.quote.displayString.distance(between: searchText, using: algorithm) ?? 0 < 0.3) ||
            $0.currency.code.distance(between: searchText, using: algorithm) == 0
        }
    }

    func filtered(by smallBalancesFilterIsOn: Bool) -> [Element] {
        filter {
            guard smallBalancesFilterIsOn == false
            else {
                return true
            }
            return $0.hasBalance
        }
    }
}
