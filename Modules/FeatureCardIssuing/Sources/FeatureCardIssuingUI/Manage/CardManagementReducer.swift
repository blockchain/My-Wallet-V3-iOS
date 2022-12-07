// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import ComposableArchitectureExtensions
import Errors
import FeatureCardIssuingDomain
import Foundation
import Localization
import MoneyKit
import PassKit
import SwiftUI
import ToolKit

enum CardManagementAction: Equatable, BindableAction {
    case addToAppleWallet
    case close
    case closeDetails
    case delete
    case deleteCardResponse(Result<Card, NabuNetworkError>)
    case getActivationUrl
    case getActivationUrlResponse(Result<URL, NabuNetworkError>)
    case getPinUrl
    case getPinUrlResponse(Result<URL, NabuNetworkError>)
    case hideActivationWebview
    case setCanAddCard(Result<Bool, Never>)
    case getCardsResponse(Result<[Card], NabuNetworkError>)
    case getCardResponse(Result<Card?, NabuNetworkError>)
    case getDocuments
    case getFulfillment
    case getFulfillmentResponse(Result<Card.Fulfillment, NabuNetworkError>)
    case getLinkedAccount
    case getLinkedAccountResponse(Result<AccountSnapshot?, Never>)
    case getCardHelperUrl
    case getCardHelperUrlResponse(Result<URL, NabuNetworkError>)
    case fetchCards
    case onAppear
    case onDisappear
    case selectLinkedAccountResponse(Result<AccountBalance, NabuNetworkError>)
    case setLinkedAccountResponse(Result<AccountCurrency, NabuNetworkError>)
    case unlockCardResponse(Result<Card, NabuNetworkError>)
    case lockCardResponse(Result<Card, NabuNetworkError>)
    case showCardDetails(Card)
    case showManagementDetails
    case showSelectLinkedAccountFlow
    case showSupportFlow
    case showTransaction(Card.Transaction)
    case openAddCardFlow
    case openBuyFlow
    case openSwapFlow
    case refreshTransactions
    case fetchTransactions
    case fetchRecentTransactions(Card)
    case fetchMoreTransactions
    case fetchTransactionsResponse(Result<[Card.Transaction], NabuNetworkError>)
    case fetchRecentTransactionsResponse(Result<[Card.Transaction], NabuNetworkError>)
    case setTransactionDetailsVisible(Bool)
    case editAddress
    case editAddressComplete(Result<CardAddressSearchResult, Never>)
    case fetchFullName
    case fetchFullNameResponse(Result<String, NabuNetworkError>)
    case fetchStatementsResponse(Result<[Statement], NabuNetworkError>)
    case fetchStatementUrl(Statement)
    case fetchStatementUrlResponse(Result<URL, NabuNetworkError>)
    case fetchLegalItemsResponse(Result<[LegalItem], NabuNetworkError>)
    case selectCard(String)
    case binding(BindingAction<CardManagementState>)
}

public struct CardManagementState: Equatable {

    @BindableState var isLocked = false
    @BindableState var isDetailScreenVisible = false
    @BindableState var isTopUpPresented = false
    @BindableState var isTransactionListPresented = false
    @BindableState var isDeleteCardPresented = false
    @BindableState var isDeleting = false
    @BindableState var isCardSelectorPresented = false
    @BindableState var isStatementsVisible = false
    @BindableState var pinUrl: LoadingState<URL>?

    var activationUrl: LoadingState<URL>?
    var selectedCard: Card?
    var canAddCards = false
    var cards: [Card] = []
    var cardHelperUrl: URL?
    var error: NabuNetworkError?
    var recentTransactions: LoadingState<[Card.Transaction]> = .loading
    var transactions: [Card.Transaction] = []
    var displayedTransaction: Card.Transaction?
    var linkedAccount: AccountSnapshot?
    var canFetchMoreTransactions = true
    var cardholderName: String
    var tokenisationCoordinator: PassTokenisationCoordinator
    var isTokenisationEnabled: Bool
    var fulfillment: Card.Fulfillment?
    var legalItems: [LegalItem]
    var statements: [Statement]

    public init(
        card: Card? = nil,
        cardholderName: String = "",
        isLocked: Bool = false,
        cardHelperUrl: URL? = nil,
        error: NabuNetworkError? = nil,
        cards: [Card] = [],
        legalItems: [LegalItem] = [],
        statements: [Statement] = [],
        transactions: [Card.Transaction] = [],
        isTokenisationEnabled: Bool = true,
        tokenisationCoordinator: PassTokenisationCoordinator
    ) {
        self.selectedCard = card
        self.cards = cards
        self.cardholderName = cardholderName
        self.isLocked = isLocked
        self.cardHelperUrl = cardHelperUrl
        self.error = error
        self.legalItems = legalItems
        self.statements = statements
        self.transactions = transactions
        self.tokenisationCoordinator = tokenisationCoordinator
        self.isTokenisationEnabled = PKAddPaymentPassViewController.canAddPaymentPass() && isTokenisationEnabled
    }
}

public protocol AccountProviderAPI {
    func selectAccount(for card: Card) -> AnyPublisher<AccountBalance, NabuNetworkError>
    func linkedAccount(for card: Card) -> AnyPublisher<AccountSnapshot?, Never>
}

public protocol TopUpRouterAPI {
    func openBuyFlow(for currency: CryptoCurrency?)
    func openBuyFlow(for currency: FiatCurrency?)
    func openSwapFlow()
}

public protocol SupportRouterAPI {
    func handleSupport()
}

public struct CardManagementEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let cardIssuingBuilder: CardIssuingBuilderAPI
    let cardService: CardServiceAPI
    let legalService: LegalServiceAPI
    let productsService: ProductsServiceAPI
    let transactionService: TransactionServiceAPI
    let accountModelProvider: AccountProviderAPI
    let topUpRouter: TopUpRouterAPI
    let supportRouter: SupportRouterAPI
    let userInfoProvider: UserInfoProviderAPI
    let addressSearchRouter: AddressSearchRouterAPI
    let notificationCenter: NotificationCenter
    let openAddCardFlow: () -> Void
    let close: () -> Void

    public init(
        accountModelProvider: AccountProviderAPI,
        cardIssuingBuilder: CardIssuingBuilderAPI,
        cardService: CardServiceAPI,
        legalService: LegalServiceAPI,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        productsService: ProductsServiceAPI,
        transactionService: TransactionServiceAPI,
        supportRouter: SupportRouterAPI,
        userInfoProvider: UserInfoProviderAPI,
        topUpRouter: TopUpRouterAPI,
        addressSearchRouter: AddressSearchRouterAPI,
        notificationCenter: NotificationCenter,
        openAddCardFlow: @escaping () -> Void,
        close: @escaping () -> Void
    ) {
        self.mainQueue = mainQueue
        self.cardIssuingBuilder = cardIssuingBuilder
        self.cardService = cardService
        self.legalService = legalService
        self.productsService = productsService
        self.transactionService = transactionService
        self.accountModelProvider = accountModelProvider
        self.supportRouter = supportRouter
        self.userInfoProvider = userInfoProvider
        self.topUpRouter = topUpRouter
        self.notificationCenter = notificationCenter
        self.addressSearchRouter = addressSearchRouter
        self.openAddCardFlow = openAddCardFlow
        self.close = close
    }
}

// swiftlint:disable closure_body_length
let cardManagementReducer: Reducer<
    CardManagementState,
    CardManagementAction,
    CardManagementEnvironment
> = Reducer<
    CardManagementState,
    CardManagementAction,
    CardManagementEnvironment
> { state, action, env in
    switch action {
    case .close:
        return .fireAndForget {
            env.close()
        }
    case .closeDetails:
        state.isDetailScreenVisible = false
        return .none
    case .onAppear:
        return .merge(
            Effect(value: .getCardHelperUrl),
            Effect(value: .refreshTransactions),
            Effect(value: .fetchFullName),
            env.productsService
                .fetchProducts()
                .map {
                    $0.filter(\.hasRemainingCards).isNotEmpty
                }
                .replaceError(with: false)
                .receive(on: env.mainQueue)
                .catchToEffect(CardManagementAction.setCanAddCard)
        )
    case .fetchCards:
        return .merge(
            env.cardService
                .fetchCards()
                .receive(on: env.mainQueue)
                .catchToEffect(CardManagementAction.getCardsResponse),
            env.productsService
                .fetchProducts()
                .map {
                    $0.filter(\.hasRemainingCards).isNotEmpty
                }
                .replaceError(with: false)
                .receive(on: env.mainQueue)
                .catchToEffect(CardManagementAction.setCanAddCard)
        )
    case .onDisappear:
        return .none
    case .getCardsResponse(.success(let cards)):
        state.cards = cards
        if let selectedCard = state.selectedCard,
           let card = cards.first(where: { $0.id == selectedCard.id })
        {
            return Effect(value: .getCardResponse(.success(card)))
        } else if let card = cards.first {
            return Effect(value: .getCardResponse(.success(card)))
        }
        return .none
    case .getCardsResponse(.failure(let error)):
        state.error = error
        return .none
    case .setCanAddCard(.success(let canAddCard)):
        state.canAddCards = canAddCard
        return .none
    case .showManagementDetails:
        state.isDetailScreenVisible = true
        return .none
    case .showSelectLinkedAccountFlow:
        guard let card = state.selectedCard else {
            return .none
        }
        return env
            .accountModelProvider
            .selectAccount(for: card)
            .subscribe(on: env.mainQueue)
            .receive(on: env.mainQueue)
            .catchToEffect(CardManagementAction.selectLinkedAccountResponse)
    case .selectLinkedAccountResponse(.success(let account)):
        guard let card = state.selectedCard else {
            return .none
        }
        return env.cardService
            .update(account: account, for: card)
            .catchToEffect(CardManagementAction.setLinkedAccountResponse)
    case .selectLinkedAccountResponse(.failure(let error)):
        state.error = error
        return .none
    case .setLinkedAccountResponse(.success(let account)):
        return Effect(value: CardManagementAction.getLinkedAccount)
    case .setLinkedAccountResponse(.failure(let error)):
        state.error = error
        return .none
    case .delete:
        guard let card = state.selectedCard else {
            return Effect(value: .close)
        }
        state.isDeleting = true
        return env.cardService
            .delete(card: card)
            .receive(on: env.mainQueue)
            .catchToEffect(CardManagementAction.deleteCardResponse)
    case .deleteCardResponse(.success):
        state.isDetailScreenVisible = false
        return Effect(value: .close)
    case .deleteCardResponse(.failure(let error)):
        state.isDetailScreenVisible = false
        state.isDeleting = false
        state.error = error
        return .none
    case .showSupportFlow:
        return .fireAndForget {
            env.supportRouter.handleSupport()
        }
    case .addToAppleWallet:
        return .none
    case .getCardResponse(.success(let card)):
        guard let card else {
            return .none
        }
        if let row = state.cards.firstIndex(where: { $0.id == card.id }) {
            state.cards[row] = card
        }
        state.selectedCard = card
        state.isLocked = card.isLocked
        return Effect.merge(
            Effect(value: CardManagementAction.getFulfillment),
            Effect(value: CardManagementAction.getLinkedAccount),
            Effect(value: CardManagementAction.getCardHelperUrl),
            Effect(value: CardManagementAction.fetchRecentTransactions(card))
        )
    case .getCardResponse(.failure(let error)):
        state.error = error
        return .none
    case .getFulfillment:
        state.fulfillment = nil
        guard let card = state.selectedCard,
              card.type == .physical,
              card.status == .unactivated
        else {
            return .none
        }
        return env.cardService
            .fulfillment(card: card)
            .receive(on: env.mainQueue)
            .catchToEffect(CardManagementAction.getFulfillmentResponse)
    case .getFulfillmentResponse(.success(let fulfillment)):
        state.fulfillment = fulfillment
        return .none
    case .getFulfillmentResponse(.failure):
        return .none
    case .getLinkedAccount:
        guard let card = state.selectedCard else {
            return .none
        }
        return env
            .accountModelProvider
            .linkedAccount(for: card)
            .receive(on: env.mainQueue)
            .catchToEffect(CardManagementAction.getLinkedAccountResponse)
    case .getLinkedAccountResponse(.success(let account)):
        state.linkedAccount = account
        return .none
    case .getCardHelperUrl:
        guard let card = state.selectedCard else { return .none }
        return env.cardService
            .helperUrl(for: card)
            .receive(on: env.mainQueue)
            .catchToEffect(CardManagementAction.getCardHelperUrlResponse)
    case .getCardHelperUrlResponse(.success(let cardHelperUrl)):
        state.cardHelperUrl = cardHelperUrl
        return .none
    case .getCardHelperUrlResponse(.failure(let error)):
        state.error = error
        return .none
    case .lockCardResponse(.success(let card)),
            .unlockCardResponse(.success(let card)):
        state.selectedCard = card
        state.isLocked = card.isLocked
        return .none
    case .unlockCardResponse(.failure), .lockCardResponse(.failure):
        state.isLocked = state.selectedCard?.isLocked ?? false
        return .none
    case .openBuyFlow:
        let linkedAccount = state.linkedAccount
        return .fireAndForget {
            guard let crypto = linkedAccount?.cryptoCurrency else {
                env.topUpRouter.openBuyFlow(for: linkedAccount?.fiatCurrency)
                return
            }
            env.topUpRouter.openBuyFlow(for: crypto)
        }
    case .openSwapFlow:
        return .fireAndForget {
            env.topUpRouter.openSwapFlow()
        }
    case .showTransaction(let transaction):
        state.displayedTransaction = transaction
        return .none
    case .refreshTransactions:
        return .merge(
            .fireAndForget {
                env
                    .notificationCenter
                    .post(name: Notification.Name.debitCardRefresh, object: nil)
            },
            Effect(value: CardManagementAction.fetchTransactions)
        )
    case .fetchTransactions:
        return env.transactionService
            .fetchTransactions()
            .receive(on: env.mainQueue)
            .catchToEffect(CardManagementAction.fetchTransactionsResponse)
    case .fetchRecentTransactions(let card):
        return env.transactionService
            .fetchTransactions(for: card)
            .receive(on: env.mainQueue)
            .catchToEffect(CardManagementAction.fetchRecentTransactionsResponse)
    case .fetchMoreTransactions:
        guard state.canFetchMoreTransactions else {
            return .none
        }
        state.canFetchMoreTransactions = false
        return env.transactionService
            .fetchMore()
            .receive(on: env.mainQueue)
            .catchToEffect(CardManagementAction.fetchTransactionsResponse)
    case .fetchTransactionsResponse(.success(let transactions)):
        state.canFetchMoreTransactions = transactions != state.transactions
        state.transactions = transactions
        return .none
    case .fetchTransactionsResponse(.failure):
        state.canFetchMoreTransactions = false
        return .none
    case .fetchRecentTransactionsResponse(.success(let transactions)):
        state.recentTransactions = .loaded(next: transactions)
        return .none
    case .fetchRecentTransactionsResponse(.failure):
        state.recentTransactions = .loaded(next: [])
        return .none
    case .editAddress:
        return env.addressSearchRouter
            .openEditAddressFlow(isPresentedFromSearchView: false)
            .receive(on: env.mainQueue)
            .catchToEffect(CardManagementAction.editAddressComplete)
    case .editAddressComplete(.success):
        return .none
    case .binding(\.$isLocked):
        guard let card = state.selectedCard else { return .none }
        switch state.isLocked {
        case true:
            return env.cardService
                .lock(card: card)
                .receive(on: env.mainQueue)
                .catchToEffect(CardManagementAction.lockCardResponse)
        case false:
            return env.cardService
                .unlock(card: card)
                .receive(on: env.mainQueue)
                .catchToEffect(CardManagementAction.unlockCardResponse)
        }
    case .setTransactionDetailsVisible(let visible):
        if !visible {
            state.displayedTransaction = nil
        }
        return .none
    case .fetchFullName:
        return env.userInfoProvider
            .fullName
            .receive(on: env.mainQueue)
            .catchToEffect(CardManagementAction.fetchFullNameResponse)
    case .fetchFullNameResponse(.success(let fullName)):
        state.cardholderName = fullName
        return .none
    case .fetchFullNameResponse(.failure):
        return .none
    case .selectCard(let cardId):
        state.isCardSelectorPresented = false
        return Effect(
            value: CardManagementAction
                .getCardResponse(
                    .success(state.cards.first { $0.id == cardId })
                )
        )
    case .showCardDetails(let card):
        state.selectedCard = card
        state.isCardSelectorPresented = false
        state.isDetailScreenVisible = true
        return Effect(value: .getCardResponse(.success(card)))
    case .openAddCardFlow:
        return .fireAndForget {
            env.openAddCardFlow()
        }
    case .getActivationUrl:
        guard state.activationUrl == nil,
             let card = state.selectedCard,
             let fulfillment = state.fulfillment,
             fulfillment.status.canActivate
        else {
           return .none
        }
        state.activationUrl = .loading
        return env.cardService
            .activateWidgetUrl(card: card)
            .receive(on: env.mainQueue)
            .catchToEffect(CardManagementAction.getActivationUrlResponse)
    case .getActivationUrlResponse(.success(let url)):
        state.activationUrl = .loaded(next: url)
        return .none
    case .getActivationUrlResponse(.failure):
        state.activationUrl = nil
        return .none
    case .getPinUrl:
        guard state.pinUrl == nil,
             let card = state.selectedCard
        else {
           return .none
        }
        state.pinUrl = .loading
        return env.cardService
            .pinWidgetUrl(card: card)
            .receive(on: env.mainQueue)
            .catchToEffect(CardManagementAction.getPinUrlResponse)
    case .getPinUrlResponse(.success(let url)):
        state.pinUrl = .loaded(next: url)
        return .none
    case .getPinUrlResponse(.failure):
        state.pinUrl = nil
        return .none
    case .hideActivationWebview:
        state.activationUrl = nil
        guard let card = state.selectedCard else {
            return .none
        }
        return env.cardService
            .fetchCard(with: card.id)
            .receive(on: env.mainQueue)
            .catchToEffect(CardManagementAction.getCardResponse)
    case .binding:
        return .none
    case .fetchStatementsResponse(.success(let statements)):
        state.statements = statements
        return .none
    case .fetchStatementsResponse(.failure):
        return .none
    case .fetchStatementUrl(let statement):
        return env.cardService.fetchStatementUrl(statement: statement).receive(on: env.mainQueue).catchToEffect(CardManagementAction.fetchStatementUrlResponse)
    case .fetchStatementUrlResponse(.success(let url)):
        return .fireAndForget {
            UIApplication.shared.open(url)
        }
    case .fetchStatementUrlResponse(.failure):
        return .none
    case .getDocuments:
        return .merge(
            env.legalService
                .fetchLegalItems()
                .receive(on: env.mainQueue)
                .catchToEffect(CardManagementAction.fetchLegalItemsResponse),
            env.cardService
                .fetchStatements()
                .receive(on: env.mainQueue)
                .catchToEffect(CardManagementAction.fetchStatementsResponse)
        )
    case .fetchLegalItemsResponse(let result):
        guard case .success(let legalItems) = result else {
            return .none
        }
        state.legalItems = legalItems
        return .none
    }
}
.binding()

extension Card.Fulfillment.Status {
    var canActivate: Bool {
        self == .shipped || self == .delivered
    }
}

#if DEBUG
extension CardManagementEnvironment {
    static var preview: CardManagementEnvironment {
        CardManagementEnvironment(
            accountModelProvider: MockServices(),
            cardIssuingBuilder: MockCardIssuingBuilder(),
            cardService: MockServices(),
            legalService: MockServices(),
            mainQueue: .main,
            productsService: MockServices(),
            transactionService: MockServices(),
            supportRouter: MockServices(),
            userInfoProvider: MockServices(),
            topUpRouter: MockServices(),
            addressSearchRouter: MockServices(),
            notificationCenter: NotificationCenter.default,
            openAddCardFlow: {},
            close: {}
        )
    }
}

extension CardManagementState {
    static var preview: CardManagementState {
        CardManagementState(
            card: nil,
            isLocked: false,
            cardHelperUrl: nil,
            error: nil,
            transactions: [.success, .pending, .failed],
            tokenisationCoordinator: PassTokenisationCoordinator(service: MockServices())
        )
    }
}

class MockCardIssuingBuilder: CardIssuingBuilderAPI {

    func makeSelectorViewController(openAddCardFlow: @escaping () -> Void, onComplete: @escaping () -> Void) -> UIViewController {
        UIViewController()
    }

    func makeIntroViewController(
        address: AnyPublisher<FeatureCardIssuingDomain.Card.Address, CardOrderingError>,
        kyc: KYC,
        onComplete: @escaping (CardOrderingResult) -> Void
    ) -> UIViewController {
        UIViewController()
    }

    func makeIntroView(
        address: AnyPublisher<FeatureCardIssuingDomain.Card.Address, CardOrderingError>,
        kyc: KYC,
        onComplete: @escaping (CardOrderingResult) -> Void
    ) -> AnyView {
        AnyView(EmptyView())
    }

    func makeManagementViewController(
        selectedCard: FeatureCardIssuingDomain.Card?,
        openAddCardFlow: @escaping () -> Void,
        onComplete: @escaping () -> Void
    ) -> UIViewController {
        UIViewController()
    }

    func makeManagementView(
        selectedCard: FeatureCardIssuingDomain.Card?,
        openAddCardFlow: @escaping () -> Void,
        onComplete: @escaping () -> Void
    ) -> AnyView {
        AnyView(EmptyView())
    }
}
#endif
