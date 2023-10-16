import BlockchainNamespace
import ComposableArchitecture
import FeatureDashboardDomain
import Foundation
import MoneyKit
import SwiftExtensions
import ToolKit

public struct AllAssetsScene: Reducer {
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
        @BindingState var searchText: String = ""
        @BindingState var isSearching: Bool = false
        @BindingState var filterPresented: Bool = false
        @BindingState var showSmallBalances: Bool = false

        var searchResults: [AssetBalanceInfo]? {
            guard let balanceInfo else {
                return nil
            }
            var base = balanceInfo.filtered(showSmallBalances: showSmallBalances)
            if base.isEmpty {
                base = balanceInfo
            }
            if searchText.isEmpty {
                return base
            } else {
                return base
                    .filtered(by: searchText)
            }
        }

        public init(with presentedAssetType: PresentedAssetType) {
            self.presentedAssetType = presentedAssetType
        }
    }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.showSmallBalances = app.state.get(
                    state.presentedAssetType.smallBalanceFilterTag,
                    as: Bool.self,
                    or: false
                )
                return .publisher { [state] in
                    app
                        .publisher(
                            for: blockchain.user.currency.preferred.fiat.display.currency,
                            as: FiatCurrency.self
                        )
                        .compactMap(\.value)
                        .flatMap { fiatCurrency -> StreamOf<[AssetBalanceInfo], Never> in
                            let cryptoPublisher = state.presentedAssetType.isCustodial
                            ? assetBalanceInfoRepository.cryptoCustodial(fiatCurrency: fiatCurrency, time: .now)
                            : assetBalanceInfoRepository.cryptoNonCustodial(fiatCurrency: fiatCurrency, time: .now)
                            return cryptoPublisher
                        }
                        .receive(on: DispatchQueue.main)
                        .map(Action.onBalancesFetched)
                }

            case .binding(\.$searchText):
                return .none

            case .binding(\.$isSearching):
                return .none

            case .onFilterTapped:
                state.filterPresented = true
                return .none

            case .onBalancesFetched(.success(let balanceinfo)):
                state.balanceInfo = balanceinfo.filter { $0.balance?.hasPositiveDisplayableBalance ?? false }
                return .none

            case .onBalancesFetched(.failure):
                return .none

            case .onAssetTapped(let assetInfo):
                app.post(
                    action: blockchain.ux.asset[assetInfo.currency.code].select.then.enter.into,
                    value: blockchain.ux.asset[assetInfo.currency.code],
                    context: [blockchain.ux.asset.select.origin: "ASSETS"]
                )
                return .none

            case .onConfirmFilterTapped:
                state.filterPresented = false
                return .none

            case .onResetTapped:
                state.showSmallBalances = false
                app.post(value: false, of: state.presentedAssetType.smallBalanceFilterTag)
                return .none

            case .binding(\.$showSmallBalances):
                return .run { [state] _ in
                    app.post(value: state.showSmallBalances, of: state.presentedAssetType.smallBalanceFilterTag)
                }

            case .binding:
                return .none
            }
        }
    }
}

extension [AssetBalanceInfo] {
    func filtered(
        by searchText: String,
        using algorithm: StringDistanceAlgorithm = FuzzyAlgorithm(caseInsensitive: true)
    ) -> [Element] {
        filter { $0.filter(by: searchText, using: algorithm) }
    }

    func filtered(showSmallBalances: Bool) -> [Element] {
        showSmallBalances ? self : filter(\.hasBalance)
    }
}

extension AssetBalanceInfo {
    func filter(
        by searchText: String,
        using algorithm: StringDistanceAlgorithm
    ) -> Bool {
        currency.filter(by: searchText, using: algorithm) ||
            fiatBalance.flatMap { $0.quote.displayString.distance(between: searchText, using: algorithm) < 0.3 } ?? false
    }
}
