import BlockchainNamespace
import ComposableArchitecture
import FeatureDashboardDomain
import Foundation
import MoneyKit
import PlatformKit
import SwiftExtensions
import ToolKit

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
                let smallBalancesFilterTag = state.presentedAssetType == .custodial ?
                blockchain.ux.dashboard.trading.assets.small.balance.filtering.is.on :
                blockchain.ux.dashboard.defi.assets.small.balance.filtering.is.on

                state.showSmallBalancesFilterIsOn = (try? app.state.get(smallBalancesFilterTag)) ?? false
                return app
                    .publisher(
                        for: blockchain.user.currency.preferred.fiat.display.currency,
                        as: FiatCurrency.self
                    )
                    .compactMap(\.value)
                    .flatMap { [state] fiatCurrency -> StreamOf<[AssetBalanceInfo], Never> in
                        let cryptoPublisher = state.presentedAssetType.isCustodial
                        ? assetBalanceInfoRepository.cryptoCustodial(fiatCurrency: fiatCurrency, time: .now)
                        : assetBalanceInfoRepository.cryptoNonCustodial(fiatCurrency: fiatCurrency, time: .now)
                        return cryptoPublisher
                    }
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
                state.balanceInfo = balanceinfo.filter(\.balance.hasPositiveDisplayableBalance)
                return .none

            case .onBalancesFetched(.failure):
                return .none

            case .onAssetTapped(let assetInfo):
                return .fireAndForget {
                    app.post(
                        action: blockchain.ux.asset[assetInfo.currency.code].select.then.enter.into,
                        value: blockchain.ux.asset[assetInfo.currency.code],
                        context: [blockchain.ux.asset.select.origin: "ASSETS"]
                    )
                }

            case .onConfirmFilterTapped:
                state.filterPresented = false
                return .none

            case .onResetTapped:
                state.showSmallBalancesFilterIsOn = false
                app.post(value: false, of: blockchain.ux.dashboard.trading.assets.small.balance.filtering.is.on)
                return .none

            case .binding(\.$showSmallBalancesFilterIsOn):
                return .fireAndForget { [state] in
                    let tag = state.presentedAssetType == .custodial ?
                    blockchain.ux.dashboard.trading.assets.small.balance.filtering.is.on :
                    blockchain.ux.dashboard.defi.assets.small.balance.filtering.is.on

                    app.post(value: state.showSmallBalancesFilterIsOn, of: tag)
                }

            case .binding:
                return .none
            }
        }
    }
}

extension [AssetBalanceInfo] {
    func filtered(by searchText: String, using algorithm: StringDistanceAlgorithm = FuzzyAlgorithm(caseInsensitive: true)) -> [Element] {
        filter {
            $0.currency.filter(by: searchText, using: algorithm) ||
            ($0.fiatBalance?.quote.displayString.distance(between: searchText, using: algorithm) ?? 1) < 0.3
        }
    }

    func filtered(by smallBalancesFilterIsOn: Bool) -> [Element] {
        filter {
            guard smallBalancesFilterIsOn == false else {
                return true
            }
            return $0.hasBalance
        }
    }
}
