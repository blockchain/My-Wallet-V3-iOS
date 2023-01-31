//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import ComposableArchitecture
import ComposableArchitectureExtensions
import ComposableNavigation
import DIKit
import FeatureAppUI
import FeatureBackupRecoveryPhraseUI
import FeatureReferralDomain
import FeatureReferralUI
import FeatureSettingsDomain
import Localization
import MoneyKit
import PlatformKit
import ToolKit

struct RootViewState: Equatable, NavigationState {
    var route: RouteIntent<RootViewRoute>?

    @BindableState var tabs: OrderedSet<Tab>?
    @BindableState var tab: Tag.Reference = blockchain.ux.user.portfolio[].reference
    @BindableState var fab: FrequentActionState
    @BindableState var referralState: ReferralState
    @BindableState var buyAndSell: BuyAndSell = .init()
    @BindableState var unreadSupportMessageCount: Int = 0
    @BindableState var appMode: AppMode?
    @BindableState var isAppModeSwitcherPresented: Bool = false
    @BindableState var appModeSeen: Bool = false
    @BindableState var superAppIsEnabled: Bool = false

    var appSwitcherEnabled: Bool {
        appMode != .universal
    }

    var appModeSwitcherState: AppModeSwitcherState?
    var accountTotals: AccountTotals?
}

extension RootViewState {
    struct BuyAndSell: Equatable {
        var segment: Int = 0
    }

    struct AccountTotals: Equatable {
        var totalBalance: MoneyValue?
        var defiWalletBalance: MoneyValue?
        var brokerageBalance: MoneyValue?
    }

    struct FrequentActionState: Equatable {
        var isOn: Bool = false
        var animate: Bool
        var data: Data?

        struct Data: Codable, Equatable {
            var list: [FrequentAction]
            var buttons: [FrequentAction]
        }
    }

    struct ReferralState: Equatable {
        var isVisible: Bool { referral != nil }
        var isHighlighted: Bool = true
        var referral: Referral?
    }

    var hideFAB: Bool {
        guard let tabs else { return true }
        return tabs.lazy.map(\.ref.tag).doesNotContain(blockchain.ux.frequent.action[])
    }
}

enum RootViewAction: Equatable, NavigationAction, BindableAction {
    case route(RouteIntent<RootViewRoute>?)
    case tab(Tag.Reference)
    case binding(BindingAction<RootViewState>)
    case onReferralTap
    case onAppear
    case onAppModeSwitcherTapped
    case onDisappear
    case onAccountTotalsFetched(RootViewState.AccountTotals)
    case appModeSwitcherAction(AppModeSwitcherAction)
}

enum RootViewRoute: NavigationRoute {
    case account
    case QR
    case referrals

    @ViewBuilder func destination(in store: Store<RootViewState, RootViewAction>) -> some View {
        switch self {
        case .QR:
            QRCodeScannerView(
                secureChannelRouter: DIKit.resolve(),
                walletConnectService: DIKit.resolve(),
                tabSwapping: DIKit.resolve()
            )
            .identity(blockchain.ux.scan.QR)
            .ignoresSafeArea()

        case .referrals:
            WithViewStore(store) { viewStore in
                if let referral = viewStore.referralState.referral {
                    ReferFriendView(store: .init(
                        initialState: .init(referralInfo: referral),
                        reducer: ReferFriendModule.reducer,
                        environment: .init(
                            mainQueue: .main
                        )
                    ))
                    .identity(blockchain.ux.referral)
                    .ignoresSafeArea()
                }
            }

        case .account:
            AccountView()
                .identity(blockchain.ux.user.account)
                .ignoresSafeArea(.container, edges: .bottom)
        }
    }
}

struct RootViewEnvironment: PublishedEnvironment {
    var subject: PassthroughSubject<(state: RootViewState, action: RootViewAction), Never> = .init()
    var app: AppProtocol
    var backupFundsRouter: RecoveryPhraseBackupRouterAPI
    var recoveryPhraseStatusProviding: RecoveryPhraseStatusProviding
    var analyticsRecorder: AnalyticsEventRecorderAPI
    private var coincore: CoincoreAPI

    init(
        app: AppProtocol,
        backupFundsRouter: RecoveryPhraseBackupRouterAPI,
        coincore: CoincoreAPI,
        recoveryPhraseStatusProviding: RecoveryPhraseStatusProviding,
        analyticsRecoder: AnalyticsEventRecorderAPI
    ) {
        self.app = app
        self.coincore = coincore
        self.recoveryPhraseStatusProviding = recoveryPhraseStatusProviding
        self.backupFundsRouter = backupFundsRouter
        self.analyticsRecorder = analyticsRecoder
    }

    func fetchTotalBalance(filter: AssetFilter) -> AnyPublisher<MoneyValue?, Never> {
        app.publisher(for: blockchain.user.currency.preferred.fiat.display.currency)
            .compactMap(\.value)
            .flatMap { [coincore] currency in
                coincore
                    .allAccounts(filter: filter)
                    .eraseError()
                    .flatMap { accountGroup -> AnyPublisher<MoneyValue, Error> in
                        accountGroup
                            .fiatBalance(fiatCurrency: currency, at: .now)
                    }
                    .optional()
                    .replaceError(with: nil)
            }
            .eraseToAnyPublisher()
    }
}

let rootMainReducer = Reducer.combine(
    rootViewReducer,
    AppModeSwitcherModule
        .reducer
        .optional()
        .pullback(
            state: \RootViewState.appModeSwitcherState,
            action: /RootViewAction.appModeSwitcherAction,
            environment: { (environment: RootViewEnvironment) in
                      AppModeSwitcherEnvironment(
                          app: environment.app,
                          recoveryPhraseStatusProviding: environment.recoveryPhraseStatusProviding,
                          backupFundsRouter: environment.backupFundsRouter,
                          analyticsRecorder: environment.analyticsRecorder
                      )
            }
        )
)

let rootViewReducer = Reducer<
    RootViewState,
    RootViewAction,
    RootViewEnvironment
> { state, action, environment in
    typealias FrequentActionData = RootViewState.FrequentActionState.Data
    switch action {
    case .tab(let tab):
        state.tab = tab
        return .none

    case .binding(\.$fab.isOn):
        if state.fab.isOn {
            state.fab.animate = false
        }
        return .none

    case .onAppModeSwitcherTapped:
        guard let appMode = state.appMode else {
            return .none
        }
        state.appModeSwitcherState = AppModeSwitcherState(
            totalAccountBalance: state.accountTotals?.totalBalance,
            defiAccountBalance: state.accountTotals?.defiWalletBalance,
            brokerageAccountBalance: state.accountTotals?.brokerageBalance,
            currentAppMode: appMode
        )
        state.isAppModeSwitcherPresented.toggle()
        return .fireAndForget {
            environment.app.post(value: true, of: blockchain.ux.app.mode.seen)
            environment.app.post(event: blockchain.ux.app.mode.switcher.tapped)
        }

    case .onAccountTotalsFetched(let accountTotals):
        state.accountTotals = RootViewState.AccountTotals(
            totalBalance: accountTotals.totalBalance,
            defiWalletBalance: accountTotals.defiWalletBalance,
            brokerageBalance: accountTotals.brokerageBalance
        )
        return .none

    case .onAppear:
        let tabsPublisher = app
            .modePublisher()
            .combineLatest(app.publisher(for: blockchain.app.configuration.app.superapp.v1.is.enabled, as: Bool.self))
            .flatMap { appMode, multiAppEnabled -> AnyPublisher<FetchResult.Value<OrderedSet<Tab>>, Never> in
                guard multiAppEnabled.value == true else {
                    if appMode == .pkw {
                        return environment
                            .app
                            .publisher(for: blockchain.app.configuration.defi.tabs, as: OrderedSet<Tab>.self)
                    }
                    return environment
                        .app
                        .publisher(for: blockchain.app.configuration.tabs, as: OrderedSet<Tab>.self)
                }

                if appMode == .pkw {
                    return environment
                        .app
                        .publisher(for: blockchain.app.configuration.superapp.defi.tabs, as: OrderedSet<Tab>.self)
                }

                if appMode == .trading {
                    return environment
                        .app
                        .publisher(for: blockchain.app.configuration.superapp.brokerage.tabs, as: OrderedSet<Tab>.self)
                }

                return environment
                    .app
                    .publisher(for: blockchain.app.configuration.tabs, as: OrderedSet<Tab>.self)
            }
            .compactMap(\.value)

        let frequentActionsPublisher = app
            .modePublisher()
            .flatMap { appMode -> AnyPublisher<FetchResult.Value<FrequentActionData>, Never> in
                switch appMode {
                case .pkw:
                    return environment
                        .app
                        .publisher(for: blockchain.app.configuration.frequent.action.pkw, as: FrequentActionData.self)

                case .trading:
                    return environment.app.publisher(for: blockchain.app.configuration.frequent.action.trading, as: FrequentActionData.self)

                case .universal:
                    return environment.app.publisher(for: blockchain.app.configuration.frequent.action, as: FrequentActionData.self)
                }
            }
            .compactMap(\.value)

        let totalsPublishers = app.on(blockchain.ux.home.event.did.pull.to.refresh)
            .receive(on: DispatchQueue.main)
            .flatMap { _ -> AnyPublisher<RootViewState.AccountTotals, Never> in
                Publishers.CombineLatest3(
                    environment
                        .fetchTotalBalance(filter: .allExcludingExchange),
                    environment
                        .fetchTotalBalance(filter: .nonCustodial),
                    environment
                        .fetchTotalBalance(filter: [.custodial, .interest, .staking])
                )
                .map {
                    RootViewState.AccountTotals(
                        totalBalance: $0,
                        defiWalletBalance: $1,
                        brokerageBalance: $2
                    )
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        return Effect<RootViewAction, Never>.merge(
            .fireAndForget {
                environment.app.state.set(blockchain.app.is.ready.for.deep_link, to: true)
            },

            environment
                .app.publisher(for: blockchain.user.referral.campaign, as: Referral.self)
                .receive(on: DispatchQueue.main)
                .compactMap(\.value)
                .eraseToEffect()
                .map { .binding(.set(\.$referralState.referral, $0)) },

            environment
                .app.publisher(for: blockchain.ux.referral.giftbox.seen, as: Bool.self)
                .replaceError(with: false)
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
                .map { .binding(.set(\.$referralState.isHighlighted, $0 == false)) },

            environment
                .app
                .publisher(for: blockchain.ux.customer.support.unread.count, as: Int.self)
                .compactMap(\.value)
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
                .map { .binding(.set(\.$unreadSupportMessageCount, $0)) },

            app.modePublisher()
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
                .map { .binding(.set(\.$appMode, $0)) },

            totalsPublishers
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
                .map(RootViewAction.onAccountTotalsFetched),

            tabsPublisher
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
                .map { .binding(.set(\.$tabs, $0)) },

            frequentActionsPublisher
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
                .map { .binding(.set(\.$fab.data, $0)) },

            environment
                .app.publisher(for: blockchain.ux.app.mode.seen, as: Bool.self)
                .replaceError(with: false)
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
                .map { .binding(.set(\.$appModeSeen, $0)) },

            environment
                .app.publisher(for: blockchain.app.configuration.app.superapp.v1.is.enabled, as: Bool.self)
                .replaceError(with: false)
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
                .map { .binding(.set(\.$superAppIsEnabled, $0)) }
        )

    case .onDisappear:
        return .fireAndForget {
            environment.app.state.set(blockchain.app.is.ready.for.deep_link, to: false)
        }

    case .onReferralTap:
        return .merge(
            .fireAndForget {
                environment.app.post(event: blockchain.ux.referral.giftbox)
                environment.app.state.set(blockchain.ux.referral.giftbox.seen, to: true)
            },
            .enter(into: .referrals, context: .none)
        )

    case .appModeSwitcherAction(let action):
        if action == .dismiss {
            state.isAppModeSwitcherPresented = false
        }
        return .none

    case .route, .binding:
        return .none
    }
}
.binding()
.routing()
.published()
