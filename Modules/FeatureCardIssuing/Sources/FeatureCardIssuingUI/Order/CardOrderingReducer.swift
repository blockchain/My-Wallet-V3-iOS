// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import ComposableArchitectureExtensions
import Errors
import FeatureCardIssuingDomain
import Localization
import MoneyKit
import PassKit
import SwiftUI
import ToolKit

public enum CardOrderingError: Error, Equatable {
    case noAddress
    case noSsn
    case noProduct
}

public enum CardOrderingResult: Equatable {
    case created(Card)
    case kyc
    case cancelled
}

enum CardOrderingAction: Equatable, BindableAction {

    case createCard
    case cardCreationResponse(Result<Card, NabuNetworkError>)
    case fetchProducts
    case productsResponse(Result<[Product], NabuNetworkError>)
    case fetchAddress
    case addressResponse(Result<Card.Address, NabuNetworkError>)
    case fetchLegalItems
    case fetchLegalItemsResponse(Result<[LegalItem], NabuNetworkError>)
    case setLegalAccepted
    case setLegalAcceptedResponse(Result<[LegalItem], NabuNetworkError>)
    case acceptLegalAction(AcceptLegalAction)
    case close(CardOrderingResult)
    case displayEligibleCountryList
    case displayEligibleStateList
    case selectProduct(Product)
    case onReviewAppear
    case fetchFullName
    case fetchFullNameResponse(Result<String, NabuNetworkError>)
    case submitKyc
    case kycResponse(Result<KYC, NabuNetworkError>)
    case editAddress
    case editAddressComplete(Result<CardAddressSearchResult, Never>)
    case editShippingAddress
    case editShippingAddressComplete(Result<CardAddressSearchResult, Never>)
    case showSupportFlow
    case binding(BindingAction<CardOrderingState>)
    case none
}

struct CardOrderingState: Equatable {

    enum Field: Equatable {
        case line1, line2, city, state, zip
    }

    enum OrderProcessingState: Equatable {
        static func == (
            lhs: CardOrderingState.OrderProcessingState,
            rhs: CardOrderingState.OrderProcessingState
        ) -> Bool {
            switch (lhs, rhs) {
            case (.processing, .processing),
                 (.success, .success),
                 (.none, .none),
                 (.error, .error):
                return true
            default:
                return false
            }
        }

        case processing
        case success(Card)
        case error(Error)
        case none
    }

    @BindableState var isOrderProcessingVisible = false
    @BindableState var isAddressConfirmationVisible = false
    @BindableState var isProductDetailsVisible = false
    @BindableState var isReviewVisible = false
    @BindableState var acceptLegalVisible = false
    @BindableState var ssn: String = ""

    var acceptLegalState: AcceptLegalState

    var updatingAddress = false
    var products: [Product] = []
    var initialKyc: KYC
    var updatedKyc: KYC?
    var selectedProduct: Product?
    var address: Card.Address?
    var shippingAddress: Card.Address?
    var fullname: String = ""
    var error: NabuNetworkError?

    var orderProcessingState: OrderProcessingState = .none

    init(
        products: [Product] = [],
        legalItems: [LegalItem] = [],
        initialKyc: KYC,
        updatedKyc: KYC? = nil,
        selectedProduct: Product? = nil,
        address: Card.Address? = nil,
        ssn: String = "",
        error: NabuNetworkError? = nil,
        orderProcessingState: CardOrderingState.OrderProcessingState = .none
    ) {
        self.products = products
        self.selectedProduct = selectedProduct
        self.address = address
        self.initialKyc = initialKyc
        self.updatedKyc = updatedKyc
        self.ssn = ssn
        self.error = error
        self.orderProcessingState = orderProcessingState
        self.acceptLegalState = AcceptLegalState(items: legalItems)
    }
}

public enum CardAddressSearchResult: Equatable {
    case abandoned
    case saved(Card.Address)
}

public protocol AddressSearchRouterAPI {
    func openSearchAddressFlow(
        prefill: Card.Address?
    ) -> AnyPublisher<CardAddressSearchResult, Never>

    func openEditAddressFlow(
        isPresentedFromSearchView: Bool
    ) -> AnyPublisher<CardAddressSearchResult, Never>
}

struct CardOrderingEnvironment {

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let cardService: CardServiceAPI
    let kycService: KYCServiceAPI
    let legalService: LegalServiceAPI
    let productsService: ProductsServiceAPI
    let residentialAddressService: CardIssuingAddressServiceAPI
    let shippingAddressService: CardIssuingAddressServiceAPI
    let addressSearchRouter: AddressSearchRouterAPI
    let shippingAddressSearchRouter: AddressSearchRouterAPI
    let userInfoProvider: UserInfoProviderAPI
    let supportRouter: SupportRouterAPI
    let onComplete: (CardOrderingResult) -> Void

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        cardService: CardServiceAPI,
        kycService: KYCServiceAPI,
        legalService: LegalServiceAPI,
        productsService: ProductsServiceAPI,
        residentialAddressService: CardIssuingAddressServiceAPI,
        shippingAddressService: CardIssuingAddressServiceAPI,
        addressSearchRouter: AddressSearchRouterAPI,
        shippingAddressSearchRouter: AddressSearchRouterAPI,
        supportRouter: SupportRouterAPI,
        userInfoProvider: UserInfoProviderAPI,
        onComplete: @escaping (CardOrderingResult) -> Void
    ) {
        self.mainQueue = mainQueue
        self.cardService = cardService
        self.kycService = kycService
        self.legalService = legalService
        self.productsService = productsService
        self.residentialAddressService = residentialAddressService
        self.shippingAddressService = shippingAddressService
        self.addressSearchRouter = addressSearchRouter
        self.shippingAddressSearchRouter = shippingAddressSearchRouter
        self.supportRouter = supportRouter
        self.userInfoProvider = userInfoProvider
        self.onComplete = onComplete
    }
}

let cardOrderingReducer: Reducer<
    CardOrderingState,
    CardOrderingAction,
    CardOrderingEnvironment
> = Reducer.combine(
    acceptLegalReducer.pullback(
        state: \.acceptLegalState,
        action: /CardOrderingAction.acceptLegalAction,
        environment: {
            AcceptLegalEnvironment(
                mainQueue: $0.mainQueue,
                legalService: $0.legalService
            )
        }
    ),
    // swiftlint:disable closure_body_length
    Reducer<CardOrderingState, CardOrderingAction, CardOrderingEnvironment> { state, action, env in
        switch action {
        case .createCard:
            state.orderProcessingState = .processing
            state.isOrderProcessingVisible = true
            guard let product = state.selectedProduct else {
                state.orderProcessingState = .error(CardOrderingError.noProduct)
                return .none
            }
            return env
                    .cardService
                    .orderCard(
                        product: product,
                        at: state.shippingAddress ?? state.address
                    )
                    .receive(on: env.mainQueue)
                    .catchToEffect(CardOrderingAction.cardCreationResponse)
        case .cardCreationResponse(.success(let card)):
            state.orderProcessingState = .success(card)
            return .none
        case .cardCreationResponse(.failure(let error)):
            state.orderProcessingState = .error(error)
            return .none
        case .fetchProducts:
            return env
                .productsService
                .fetchProducts()
                .receive(on: env.mainQueue)
                .catchToEffect(CardOrderingAction.productsResponse)
        case .productsResponse(.success(let products)):
            state.products = products.sorted(by: { lhs, rhs -> Bool in
                switch (lhs.hasRemainingCards, rhs.hasRemainingCards) {
                case (true, false):
                    return true
                default:
                    return false
                }
            })
            state.selectedProduct = state.products[safe: 0]
            return .none
        case .productsResponse(.failure(let error)):
            state.error = error
            return .none
        case .close(let result):
            return .fireAndForget {
                env.onComplete(result)
            }
        case .displayEligibleStateList:
            return .none
        case .displayEligibleCountryList:
            return .none
        case .selectProduct(let product):
            state.selectedProduct = product
            return .none
        case .fetchAddress:
            state.updatingAddress = true
            return env
                .residentialAddressService
                .fetchAddress()
                .receive(on: env.mainQueue)
                .catchToEffect(CardOrderingAction.addressResponse)
        case .addressResponse(.success(let address)):
            state.updatingAddress = false
            state.address = address
            return .none
        case .addressResponse(.failure(let error)):
            state.isAddressConfirmationVisible = false
            state.error = error
            return .none
        case .editAddress:
            guard state.address?.country != nil else {
                return .none
            }
            return env.addressSearchRouter
                .openSearchAddressFlow(prefill: state.address)
                .receive(on: env.mainQueue)
                .catchToEffect(CardOrderingAction.editAddressComplete)
        case .editAddressComplete(.success(let addressResult)):
            switch addressResult {
            case .saved(let address):
                state.address = address
            case .abandoned:
                break
            }
            return .none
        case .editShippingAddress:
            guard (state.shippingAddress?.country ?? state.address?.country) != nil else {
                return .none
            }
            return env.shippingAddressSearchRouter
                .openSearchAddressFlow(
                    prefill: .init(
                        line1: nil,
                        line2: nil,
                        city: nil,
                        postCode: nil,
                        state: nil,
                        country: state.address?.country
                    )
                )
                .receive(on: env.mainQueue)
                .catchToEffect(CardOrderingAction.editShippingAddressComplete)
        case .editShippingAddressComplete(.success(let addressResult)):
            switch addressResult {
            case .saved(let address):
                state.shippingAddress = address
            case .abandoned:
                break
            }
            return .none
        case .binding:
            return .none
        case .fetchLegalItems:
            return env.legalService
                .fetchLegalItems()
                .receive(on: env.mainQueue)
                .catchToEffect(CardOrderingAction.fetchLegalItemsResponse)
        case .fetchLegalItemsResponse(.success(let items)):
            state.acceptLegalState.items = items
            return .none
        case .fetchLegalItemsResponse(.failure(let error)):
            return .none
        case .setLegalAccepted:
            guard let accepted = state.acceptLegalState.accepted.value else {
                return .none
            }
            if accepted {
                state.acceptLegalState.accepted = .loaded(next: false)
            } else {
                if state.acceptLegalState.items.contains(where: { $0.acceptedVersion != $0.version }) {
                    return env
                        .legalService
                        .setAccepted(legalItems: state.acceptLegalState.items)
                        .receive(on: env.mainQueue)
                        .catchToEffect(CardOrderingAction.setLegalAcceptedResponse)
                } else {
                    state.acceptLegalState.accepted = .loaded(next: true)
                }
            }
            return .none
        case .setLegalAcceptedResponse(.success(let items)):
            state.acceptLegalState.accepted = .loaded(next: true)
            state.acceptLegalState.items = items
            return .none
        case .setLegalAcceptedResponse(.failure(let error)):
            state.acceptLegalState.accepted = .loaded(next: false)
            state.acceptLegalState.error = error
            return .none
        case .fetchFullName:
            return env.userInfoProvider.fullName
                .receive(on: env.mainQueue)
                .catchToEffect(CardOrderingAction.fetchFullNameResponse)
        case .fetchFullNameResponse(.success(let fullname)):
            state.fullname = fullname
            return .none
        case .fetchFullNameResponse(.failure):
            return .none
        case .acceptLegalAction(let legalAction):
            switch legalAction {
            case .close:
                state.acceptLegalVisible = false
                return .none
            default:
                ()
            }
            return .none
        case .showSupportFlow:
            return .fireAndForget {
                env.supportRouter.handleSupport()
            }
        case .submitKyc:
            let unverified = state.initialKyc.status == .unverified
            let address = state.initialKyc.hasError(.residentialAddress) || unverified ? state.address : nil
            let ssn = state.initialKyc.hasError(.ssn) || unverified ? state.ssn : nil
            return env.kycService
                .update(
                    address: address,
                    ssn: ssn
                )
                .receive(on: env.mainQueue)
                .catchToEffect(CardOrderingAction.kycResponse)
        case .kycResponse(let result):
            switch result {
            case .success(let kyc):
                state.updatedKyc = kyc
            case .failure(let error):
                state.error = error
            }
            return .none
        case .onReviewAppear:
            guard state.selectedProduct?.type == .physical,
                  (state.shippingAddress ?? state.address) == nil
            else {
                return Effect(value: .fetchFullName)
            }
            return Effect.merge(
                Effect(value: .fetchFullName),
                Effect(value: .fetchAddress)
            )
        case .none:
            return .none
        }
    }
    .binding()
)

extension KYC {

    func hasError(_ field: KYC.Field) -> Bool {
        (errorFields ?? []).contains(field)
    }
}

#if DEBUG
extension CardOrderingEnvironment {
    static var preview: CardOrderingEnvironment {
        CardOrderingEnvironment(
            mainQueue: .main,
            cardService: MockServices(),
            kycService: MockServices(),
            legalService: MockServices(),
            productsService: MockServices(),
            residentialAddressService: MockServices(),
            shippingAddressService: MockServices(),
            addressSearchRouter: MockServices(),
            shippingAddressSearchRouter: MockServices(),
            supportRouter: MockServices(),
            userInfoProvider: MockServices(),
            onComplete: { _ in }
        )
    }
}

struct MockServices: CardServiceAPI,
    ProductsServiceAPI,
    AccountProviderAPI,
    TopUpRouterAPI,
    SupportRouterAPI,
    CardIssuingAddressServiceAPI
{

    static let addressId = "GB|RM|B|27354762"

    static let address = Card.Address(
        line1: "614 Lorimer Street",
        line2: nil,
        city: "",
        postCode: "11111",
        state: "CA",
        country: "US"
    )

    let error = NabuError(id: "mock", code: .stateNotEligible, type: .unknown, description: "")
    static let card = Card(
        id: "",
        type: .virtual,
        last4: "1234",
        expiry: "12/99",
        brand: .visa,
        status: .active,
        createdAt: "01/10"
    )

    let accountCurrencyPair = AccountCurrency(
        accountCurrency: "BTC"
    )
    let accountBalancePair = AccountBalance(
        balance: Money(
            value: "50000",
            symbol: "BTC"
        )
    )
    let settings = CardSettings(
        locked: true,
        swipePaymentsEnabled: true,
        contactlessPaymentsEnabled: true,
        preAuthEnabled: true,
        address: Card.Address(
            line1: "48 rue de la Santé",
            line2: nil,
            city: "Paris",
            postCode: "75001",
            state: nil,
            country: "FR"
        )
    )

    func orderCard(
        product: Product,
        at address: Card.Address?
    ) -> AnyPublisher<Card, NabuNetworkError> {
        .just(Self.card)
    }

    func fetchCards() -> AnyPublisher<[Card], NabuNetworkError> {
        .just([Self.card])
    }

    func fetchCard(with id: String) -> AnyPublisher<Card?, NabuNetworkError> {
        .just(Self.card)
    }

    func delete(card: Card) -> AnyPublisher<Card, NabuNetworkError> {
        .just(Self.card)
    }

    func helperUrl(for card: Card) -> AnyPublisher<URL, NabuNetworkError> {
        .just(URL(string: "https://blockchain.com/")!)
    }

    func generatePinToken(for card: Card) -> AnyPublisher<String, NabuNetworkError> {
        .just("")
    }

    func fetchLinkedAccount(for card: Card) -> AnyPublisher<AccountCurrency, NabuNetworkError> {
        .just(accountCurrencyPair)
    }

    func update(account: AccountBalance, for card: Card) -> AnyPublisher<AccountCurrency, NabuNetworkError> {
        .just(accountCurrencyPair)
    }

    func fetchProducts() -> AnyPublisher<[Product], NabuNetworkError> {
        .just([
            Product(productCode: "0", price: .init(value: "0.0", symbol: "BTC"), brand: .visa, type: .virtual, remainingCards: 1),
            Product(productCode: "1", price: .init(value: "0.1", symbol: "BTC"), brand: .visa, type: .physical, remainingCards: 0)
        ])
    }

    func eligibleAccounts(for card: Card) -> AnyPublisher<[AccountBalance], NabuNetworkError> {
        .just([accountBalancePair])
    }

    func selectAccount(for card: Card) -> AnyPublisher<AccountBalance, NabuNetworkError> {
        .just(accountBalancePair)
    }

    func linkedAccount(for card: Card) -> AnyPublisher<AccountSnapshot?, Never> {
        .just(nil)
    }

    func lock(card: Card) -> AnyPublisher<Card, NabuNetworkError> {
        .just(Self.card)
    }

    func unlock(card: Card) -> AnyPublisher<Card, NabuNetworkError> {
        .just(Self.card)
    }

    func openBuyFlow(for currency: CryptoCurrency?) {}

    func openBuyFlow(for currency: FiatCurrency?) {}

    func openSwapFlow() {}

    func handleSupport() {}

    func fetchAddress() -> AnyPublisher<Card.Address, NabuNetworkError> {
        .just(Self.address)
    }

    func update(address: Card.Address) -> AnyPublisher<Card.Address, NabuNetworkError> {
        .just(Self.address)
    }

    func tokenise(
        card: Card,
        with certificates: [Data],
        nonce: Data,
        nonceSignature: Data
    ) -> AnyPublisher<PKAddPaymentPassRequest, Errors.NabuNetworkError> {
        .just(PKAddPaymentPassRequest())
    }

    func fulfillment(card: Card) -> AnyPublisher<Card.Fulfillment, NabuNetworkError> {
        .just(.init(status: .shipped))
    }

    func pinWidgetUrl(card: FeatureCardIssuingDomain.Card) -> AnyPublisher<URL, Errors.NabuNetworkError> {
        .just(URL("https://blockchain.com"))
    }

    func activateWidgetUrl(card: FeatureCardIssuingDomain.Card) -> AnyPublisher<URL, Errors.NabuNetworkError> {
        .just(URL("https://blockchain.com"))
    }

    func fetchStatements() -> AnyPublisher<[FeatureCardIssuingDomain.Statement], Errors.NabuNetworkError> {
        .just([])
    }

    func fetchStatementUrl(statement: FeatureCardIssuingDomain.Statement) -> AnyPublisher<URL, Errors.NabuNetworkError> {
        .just(URL("https://blockchain.com"))
    }
}

extension MockServices: TransactionServiceAPI {

    func fetchMore(for card: Card?) -> AnyPublisher<[Card.Transaction], NabuNetworkError> {
        .just([])
    }

    func fetchTransactions(for card: Card?) -> AnyPublisher<[Card.Transaction], NabuNetworkError> {
        .just([])
    }
}

extension MockServices: KYCServiceAPI {

    func update(address: FeatureCardIssuingDomain.Card.Address?, ssn: String?) -> AnyPublisher<FeatureCardIssuingDomain.KYC, Errors.NabuNetworkError> {
        .just(KYC(status: .success, errorFields: nil))
    }

    func fetch() -> AnyPublisher<FeatureCardIssuingDomain.KYC, Errors.NabuNetworkError> {
        .just(KYC(status: .success, errorFields: nil))
    }
}

extension MockServices: LegalServiceAPI {

    func fetchLegalItems() -> AnyPublisher<[LegalItem], NabuNetworkError> {
        .just([
            .init(
                url: URL(string: "https://www.blockchain.com/legal/#short-form-disclosure")!,
                version: 1,
                name: "short-form-disclosure",
                displayName: "Short Form Disclosure",
                acceptedVersion: 0
            ),
            .init(
                url: URL(string: "https://www.blockchain.com/legal/#terms-and-conditions")!,
                version: 2,
                name: "terms-and-conditions",
                displayName: "Terms & Conditions"
            )
        ])
    }

    func setAccepted(legalItems: [LegalItem]) -> AnyPublisher<[LegalItem], NabuNetworkError> {
        .just([])
    }
}

extension MockServices: AddressSearchRouterAPI {
    func openSearchAddressFlow(
        prefill: Card.Address?
    ) -> AnyPublisher<CardAddressSearchResult, Never> {
        .just(.saved(MockServices.address))
    }

    func openEditAddressFlow(
        isPresentedFromSearchView: Bool
    ) -> AnyPublisher<CardAddressSearchResult, Never> {
        .just(.saved(MockServices.address))
    }
}

extension MockServices: UserInfoProviderAPI {
    var fullName: AnyPublisher<String, Errors.NabuNetworkError> {
        .just("Clément approve")
    }
}
#endif
