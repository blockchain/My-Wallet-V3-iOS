// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import FeatureCardPaymentDomain
import Localization
import MoneyKit
import RxRelay
import RxSwift
import RxToolKit
import ToolKit

/// The type of payment method
public enum PaymentMethodType: Equatable, Identifiable {

    /// A card payment method (from the user's buy data)
    case card(CardData)

    /// An account for an asset. Currency supports fiat
    case account(FundData)

    /// An Apple Pay payment method (from the user's buy data)
    case applePay(CardData)

    /// A linked account bank
    case linkedBank(LinkedBankData)

    /// Suggested payment methods (e.g bank-wire / card)
    case suggested(PaymentMethod)

    /// UX associated with the payment method type.
    /// EX: A card that is not permitted or has a high failure rate
    public var ux: UX.Dialog? {
        switch self {
        case .card(let data),
             .applePay(let data):
            return data.ux
        default:
             return nil
        }
    }

    /// Some payment methods are blocked due to high failure rate
    public var block: Bool {
        switch self {
        case .card(let data),
             .applePay(let data):
            return data.block
        default:
             return false
        }
    }

    public var method: PaymentMethod.MethodType {
        switch self {
        case .card(let data):
            return .card([data.type])
        case .applePay(let data):
            return .applePay([data.type])
        case .account(let data):
            return .funds(data.topLimit.currencyType)
        case .suggested(let method):
            return method.type
        case .linkedBank(let data):
            return .bankTransfer(data.currency.currencyType)
        }
    }

    public var currency: CurrencyType {
        // Make sure to use the limits returned with the payment method, not the currency of the linked data.
        // The currency of the linked data is specific to the payment method's underlying, but the limits get converted into the wallet currency.
        // This fixes IOS-5671.
        switch self {
        case .card(let data):
            return .fiat(data.topLimit.currency)
        case .applePay(let data):
            return .fiat(data.topLimit.currency)
        case .account(let data):
            return data.topLimit.currencyType
        case .suggested(let method):
            return method.max.currencyType
        case .linkedBank(let bank):
            return bank.topLimit.currencyType
        }
    }

    public var isSuggested: Bool {
        switch self {
        case .card,
             .account,
             .linkedBank,
             .applePay:
            return false
        case .suggested:
            return true
        }
    }

    public var label: String {
        switch self {
        case .account(let fundData):
            return fundData.label
        case .card(let card):
            return card.displayLabel
        case .applePay:
            return LocalizationConstants.LineItem.Transactional.applePay
        case .linkedBank(let data):
            return data.label
        case .suggested(let paymentMethod):
            return paymentMethod.label
        }
    }

    public var id: String {
        switch self {
        case .account(let fundData):
            return fundData.topLimit.currency.code
        case .card(let card):
            return card.identifier
        case .applePay:
            return ""
        case .linkedBank(let data):
            return data.identifier
        case .suggested:
            return method.rawType.rawValue
        }
    }

    public var methodId: String? {
        switch self {
        case .card(let card):
            return card.identifier
        case .suggested:
            return nil
        case .applePay:
            return nil
        case .linkedBank(let data):
            return data.identifier
        case .account:
            return nil
        }
    }

    public var balance: MoneyValue {
        switch self {
        case .account(let funds):
            return funds.balance.moneyValue
        case .card(let cardData):
            return cardData.topLimit.moneyValue
        case .applePay(let cardData):
            return cardData.topLimit.moneyValue
        case .linkedBank(let bankData):
            return bankData.topLimit.moneyValue
        case .suggested(let paymentMethod):
            return paymentMethod.max.moneyValue
        }
    }

    public var topLimit: MoneyValue {
        switch self {
        case .account(let funds):
            return funds.topLimit.moneyValue
        case .card(let cardData):
            return cardData.topLimit.moneyValue
        case .applePay(let cardData):
            return cardData.topLimit.moneyValue
        case .linkedBank(let bankData):
            return bankData.topLimit.moneyValue
        case .suggested(let paymentMethod):
            return paymentMethod.max.moneyValue
        }
    }
}

public enum PaymentMethodTypesServiceError: Error {
    case other(Error)
}

public protocol PaymentMethodTypesServiceAPI {

    var paymentMethodTypesValidForBuy: AnyPublisher<[PaymentMethodType], PaymentMethodTypesServiceError> { get }

    var suggestedPaymentMethodTypes: Single<[PaymentMethodType]> { get }

    /// Streams the current payment method types for `Buy`
    var methodTypes: Observable<[PaymentMethodType]> { get }

    /// Streams any linked card
    var cards: Observable<[CardData]> { get }

    /// Streams any linked banks
    var linkedBanks: Observable<[LinkedBankData]> { get }

    /// A `BehaviorRelay` to adjust the preferred method type
    var preferredPaymentMethodTypeRelay: BehaviorRelay<PaymentMethodType?> { get }

    /// Streams the preferred method type
    var preferredPaymentMethodType: Observable<PaymentMethodType?> { get }

    /// Fetches eligible payment methods for a given currence
    ///
    /// - Parameter currency: A `FiatCurrency`
    func eligiblePaymentMethods(for currency: FiatCurrency) -> AnyPublisher<[PaymentMethodType], Error>

    /// Fetches any linked cards and marks the given cardId as the preferred payment method
    ///
    /// - Parameter cardId: A `String` for the bank account to be preferred
    /// - Returns: A `Completable` trait indicating the action is completed
    func fetchCards(andPrefer cardId: String) -> Completable

    /// Fetches any linked cards and marks the given cardId as the preferred payment method
    ///
    /// - Parameter cardId: A `String` for the bank account to be preferred
    /// - Returns: A `Completable` trait indicating the action is completed
    func fetchCardsPublisher(andPrefer cardId: String) -> AnyPublisher<EmptyValue, Error>

    /// Fetches any linked banks and marks the given bankId as the preferred payment method
    ///
    /// - Parameter bankId: A `String` for the bank account to be preferred
    /// - Returns: A `Completable` trait indicating the action is completed
    func fetchLinkBanks(andPrefer bankId: String) -> Completable

    /// Returns a `Bool` indicating if the given FiatCurrency can be used
    /// as a bank payment method.
    /// - Parameter fiatCurrency: The fiat currency
    func canTransactWithBankPaymentMethods(fiatCurrency: FiatCurrency) -> AnyPublisher<Bool, Error>

    /// Fetches an array of supported fiat currencies for bank transactions.
    ///
    /// - Parameter fiatCurrency: The fiat currency
    /// - Returns: A `Single` of `[FiatCurrency]` that are supported.
    func fetchSupportedCurrenciesForBankTransactions(fiatCurrency: FiatCurrency) -> AnyPublisher<[FiatCurrency], Error>

    /// Clears a previously preferred payment, if needed, useful when deleting a card or linked bank.
    /// If the given id doesn't match the current payment method, this will do nothing
    func clearPreferredPaymentIfNeeded(by id: String)
}

/// A service that aggregates all the payment method types and possible methods.
final class PaymentMethodTypesService: PaymentMethodTypesServiceAPI {

    // MARK: - Exposed

    var paymentMethodTypesValidForBuy: AnyPublisher<[PaymentMethodType], PaymentMethodTypesServiceError> {
        fiatCurrencyService
            .tradingCurrencyPublisher
            .setFailureType(to: PaymentMethodTypesServiceError.self)
            .combineLatest(
                kycTiersService.tiers
                    .map(\.isVerifiedApproved)
                    .mapError(PaymentMethodTypesServiceError.other),
                featureFlagsService
                    .isEnabled(.openBanking)
                    .mapError(PaymentMethodTypesServiceError.other)
            )
            .flatMap { [methodTypes] fiatCurrency, isVerifiedApproved, isOpenBankingEnabled in
                // In case of no preselection we want the first eligible, if none present, check if available is only 1 and
                // preselect it. Otherwise, don't preselect anything, this is in parallel with Android logic
                methodTypes
                    .map { (types: [PaymentMethodType]) -> [PaymentMethodType] in
                        // we filter valid methods for buy
                        types.filterValidForBuy(
                            currentWalletCurrency: fiatCurrency,
                            accountForEligibility: isVerifiedApproved,
                            isOpenBankingEnabled: isOpenBankingEnabled
                        )
                    }
                    .asPublisher()
                    .mapError(PaymentMethodTypesServiceError.other)
                    .eraseToAnyPublisher()
            }
            .removeDuplicates()
            .shareReplay()
    }

    var suggestedPaymentMethodTypes: Single<[PaymentMethodType]> {
        paymentMethodsService
            .paymentMethodsSingle
            .map { paymentMethods in
                paymentMethods.map { paymentMethod in
                    .suggested(paymentMethod)
                }
            }
    }

    var methodTypes: Observable<[PaymentMethodType]> {
        provideMethodTypes()
    }

    var cards: Observable<[CardData]> {
        methodTypes.map(\.cards)
    }

    var linkedBanks: Observable<[LinkedBankData]> {
        methodTypes.map(\.linkedBanks)
    }

    /// Preferred payment method
    let preferredPaymentMethodTypeRelay = BehaviorRelay<PaymentMethodType?>(value: nil)
    var preferredPaymentMethodType: Observable<PaymentMethodType?> {
        preferredPaymentMethodTypeRelay.asObservable()
            .flatMap(weak: self) { (self, paymentMethod) in
                guard let paymentMethod else {
                    return self.defaultPaymentMethod
                }
                return .just(paymentMethod)
            }
    }

    /// If there is no preferred `PaymentMethodType` selected, this is the value to which the stream should default to.
    private var defaultPaymentMethod: Observable<PaymentMethodType?> {
        paymentMethodTypesValidForBuy
            .map(\.first)
            .asObservable()
            .catchAndReturn(.none)
    }

    // MARK: - Injected

    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let paymentMethodsService: PaymentMethodsServiceAPI
    private let cardListService: CardListServiceAPI
    private let tradingBalanceService: TradingBalanceServiceAPI
    private let linkedBankService: LinkedBanksServiceAPI
    private let beneficiariesServiceUpdater: BeneficiariesServiceUpdaterAPI
    private let kycTiersService: KYCTiersServiceAPI
    private let featureFlagsService: FeatureFlagsServiceAPI

    // MARK: - Setup

    init(
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        paymentMethodsService: PaymentMethodsServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        cardListService: CardListServiceAPI = resolve(),
        tradingBalanceService: TradingBalanceServiceAPI = resolve(),
        linkedBankService: LinkedBanksServiceAPI = resolve(),
        beneficiariesServiceUpdater: BeneficiariesServiceUpdaterAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve(),
        notificationCenter: NotificationCenter = .default
    ) {
        self.enabledCurrenciesService = enabledCurrenciesService
        self.paymentMethodsService = paymentMethodsService
        self.fiatCurrencyService = fiatCurrencyService
        self.cardListService = cardListService
        self.tradingBalanceService = tradingBalanceService
        self.linkedBankService = linkedBankService
        self.beneficiariesServiceUpdater = beneficiariesServiceUpdater
        self.kycTiersService = kycTiersService
        self.featureFlagsService = featureFlagsService
        notificationCenter.when(.login) { [weak self] _ in
            self?.preferredPaymentMethodTypeRelay.accept(nil)
        }
        notificationCenter.when(.logout) { [weak self] _ in
            self?.preferredPaymentMethodTypeRelay.accept(nil)
        }
    }

    func canTransactWithBankPaymentMethods(
        fiatCurrency: FiatCurrency
    ) -> AnyPublisher<Bool, Error> {
        guard fiatCurrency.isBankWireSupportedCurrency else {
            return .just(false)
        }
        let supportedCurrencies = fetchSupportedCurrenciesForBankTransactions(
            fiatCurrency: fiatCurrency
        )
        return supportedCurrencies
            .map { currencies in
                if fiatCurrency.isACHSupportedCurrency {
                    return currencies.contains(fiatCurrency)
                }
                // Filter out all currencies that are supported for ACH.
                // If ACH is disabled, the user should not be able to transact.
                // If ACH is enabled but the currency is not an ACH supported currency
                // the currency will be available.
                let available = currencies.filter { !$0.isACHSupportedCurrency }
                return available.contains(fiatCurrency)
            }
            .eraseToAnyPublisher()
    }

    func eligiblePaymentMethods(
        for currency: FiatCurrency
    ) -> AnyPublisher<[PaymentMethodType], Error> {
        paymentMethodsService
            .supportedPaymentMethods(for: currency)
            .map { paymentMethods in
                paymentMethods.map(PaymentMethodType.suggested)
            }
            .eraseToAnyPublisher()
    }

    func fetchSupportedCurrenciesForBankTransactions(
        fiatCurrency: FiatCurrency
    ) -> AnyPublisher<[FiatCurrency], Error> {
        eligiblePaymentMethods(for: fiatCurrency)
            .map { paymentMethods -> [PaymentMethodType] in
                paymentMethods.filter {
                    guard case .fiat(let currency) = $0.currency else { return false }
                    guard fiatCurrency == currency else { return false }
                    return ($0.method.isBankAccount || $0.method.isBankTransfer)
                }
            }
            .map { $0.map(\.currency.fiatCurrency!) }
            .eraseToAnyPublisher()
    }

    func fetchCards(andPrefer cardId: String) -> Completable {
        Single
            .zip(
                paymentMethodsService.paymentMethodsSingle,
                cardListService.fetchCards().asSingle(),
                tradingBalanceService.balances.asSingle()
            )
            .map {
                (
                    paymentMethods: $0.0,
                    cards: $0.1,
                    balances: $0.2
                )
            }
            .map(weak: self) { (self, payload) in
                self.merge(
                    paymentMethods: payload.paymentMethods,
                    cards: payload.cards,
                    balances: payload.balances,
                    linkedBanks: []
                )
            }
            .do(onSuccess: { [weak preferredPaymentMethodTypeRelay] types in
                let card = types
                    .compactMap { type -> CardData? in
                        switch type {
                        case .card(let cardData),
                             .applePay(let cardData):
                            return cardData
                        case .suggested, .account, .linkedBank:
                            return nil
                        }
                    }
                    .first
                guard let data = card else { return }
                preferredPaymentMethodTypeRelay?.accept(.card(data))
            })
            .asCompletable()
    }

    func fetchCardsPublisher(andPrefer cardId: String) -> AnyPublisher<EmptyValue, Error> {
        fetchCards(andPrefer: cardId)
            .andThen(Single<EmptyValue>.just(.noValue))
            .asObservable()
            .asPublisher()
            .eraseError()
            .eraseToAnyPublisher()
    }

    func fetchLinkBanks(andPrefer bankId: String) -> Completable {
        Single
            .zip(
                paymentMethodsService.paymentMethodsSingle,
                cardListService.cards.asSingle(),
                tradingBalanceService.balances.asSingle(),
                linkedBankService.fetchLinkedBanks()
            )
            .map {
                (
                    paymentMethods: $0.0,
                    cards: $0.1,
                    balances: $0.2,
                    linkedBanks: $0.3
                )
            }
            .map(weak: self) { (self, payload) in
                self.merge(
                    paymentMethods: payload.paymentMethods,
                    cards: payload.cards,
                    balances: payload.balances,
                    linkedBanks: payload.linkedBanks
                )
            }
            .map { types in
                types
                    .compactMap { type -> LinkedBankData? in
                        switch type {
                        case .linkedBank(let bankData):
                            return bankData
                        case .suggested, .account, .card, .applePay:
                            return nil
                        }
                    }
                    .first(where: { $0.identifier == bankId })
            }
            .do(onSuccess: { [weak preferredPaymentMethodTypeRelay, beneficiariesServiceUpdater] linkedBank in
                guard let data = linkedBank else { return }
                beneficiariesServiceUpdater.markForRefresh()
                preferredPaymentMethodTypeRelay?.accept(.linkedBank(data))
            })
            .asCompletable()
    }

    func clearPreferredPaymentIfNeeded(by id: String) {
        if preferredPaymentMethodTypeRelay.value?.id == id {
            preferredPaymentMethodTypeRelay.accept(nil)
        }
    }

    // MARK: - Private

    /// Merges the given payment types and order them in accordance to business rules
    /// - Parameters:
    ///   - paymentMethods: An array of `PaymentMethod` that defines the suggested methods
    ///   - cards: An array of `CardData` the defines the available cards
    ///   - balances: An instance of `CustodialAccountBalanceStates` that provides access to balance pairs
    ///   - linkedBanks: A array of `LinkedBankData` that defines any link bank (specifically ACH or OpenBanking)
    /// - Returns: An sorted array of `PaymentMethodType`
    /// ~~~
    /// Ordering:
    /// - Balances
    /// - Cards
    /// - Linked Banks
    /// - Suggested Methods
    /// ~~~
    private func merge(
        paymentMethods: [PaymentMethod],
        cards: [CardData],
        balances: CustodialAccountBalanceStates,
        linkedBanks: [LinkedBankData]
    ) -> [PaymentMethodType] {
        let topCardLimit = (paymentMethods.first { $0.type.isCard })?.max

        let cardTypes = cards
            .filter(\.state.isUsable)
            .map { card in
                var card = card
                if let limit = topCardLimit {
                    card.topLimit = limit.convert(using: .one(currency: card.currency))
                }
                return card
            }
            .map { PaymentMethodType.card($0) }

        let suggestedMethods = paymentMethods
            .filter { paymentMethod -> Bool in
                switch paymentMethod.type {
                case .bankAccount,
                     .card,
                     .applePay:
                    return true
                case .bankTransfer:
                    return true
                case .funds(let currency):
                    switch currency {
                    case .crypto:
                        return true
                    case .fiat(let fiatCurrency):
                        return FiatCurrency.allEnabledFiatCurrencies.contains(fiatCurrency)
                    }
                }
            }
            .sorted()
            .map { PaymentMethodType.suggested($0) }

        let balancesResult = paymentMethods
            .filter(\.type.isFunds)
            .compactMap { paymentMethod -> FundData? in
                guard case .funds(let currency) = paymentMethod.type else {
                    return nil
                }
                guard let balance = balances[currency].balance else {
                    return nil
                }
                return FundData(balance: balance, max: paymentMethod.max)
            }
            .map(PaymentMethodType.account)

        let activeBanks = linkedBanks.filter(\.isActive)
            .map { bank in
                var bank = bank
                bank.topLimit = paymentMethods.topLimit(bank: bank) ?? bank.topLimit
                return bank
            }
            .map { PaymentMethodType.linkedBank($0) }

        // Dear future developer,
        // Please note that order matters, if needed to change the order, remember to also update the method's comment!
        return balancesResult + cardTypes + activeBanks + suggestedMethods
    }

    private func provideMethodTypes() -> Observable<[PaymentMethodType]> {
        Observable
            .combineLatest(
                paymentMethodsService.paymentMethods,
                cardListService.cards.asObservable(),
                tradingBalanceService.balances.asObservable(),
                linkedBankService.fetchLinkedBanks().asObservable()
            )
            .map {
                (
                    paymentMethods: $0.0,
                    cards: $0.1,
                    balances: $0.2,
                    linkedBanks: $0.3
                )
            }
            .map(weak: self) { (self, payload) in
                self.merge(
                    paymentMethods: payload.paymentMethods,
                    cards: payload.cards,
                    balances: payload.balances,
                    linkedBanks: payload.linkedBanks
                )
            }
    }
}

extension [PaymentMethodType] {

    var suggestedFunds: Set<FiatCurrency> {
        let array = compactMap { paymentMethod -> FiatCurrency? in
            guard case .suggested(let method) = paymentMethod else {
                return nil
            }
            switch method.type {
            case .bankTransfer(let currencyType):
                return FiatCurrency(code: currencyType.code)
            case .funds(let currencyType):
                guard currencyType != .fiat(.USD) else {
                    return nil
                }
                return FiatCurrency(code: currencyType.code)
            case .bankAccount, .card, .applePay:
                return nil
            }
        }
        return Set(array)
    }

    fileprivate var cards: [CardData] {
        compactMap { paymentMethod in
            switch paymentMethod {
            case .card(let data), .applePay(let data):
                return data
            case .suggested, .account, .linkedBank:
                return nil
            }
        }
    }

    var linkedBanks: [LinkedBankData] {
        compactMap { paymentMethod in
            switch paymentMethod {
            case .linkedBank(let data):
                return data
            case .suggested, .account, .card, .applePay:
                return nil
            }
        }
    }

    var accounts: [FundData] {
        compactMap { paymentMethod in
            switch paymentMethod {
            case .account(let data):
                return data
            case .suggested, .card, .linkedBank, .applePay:
                return nil
            }
        }
    }

    /// Returns the payment methods valid for buy usage
    /// - Parameters:
    ///   - currentWalletCurrency: The current currency selected in settings
    ///   - accountForEligibility: Pass `true` if the eligibly flag of a suggested paymentMethod should be taken in consideration,
    ///                            otherwise `false`
    /// - Returns: An array of `PaymentMethodType` objects that are valid for buy
    public func filterValidForBuy(
        currentWalletCurrency: FiatCurrency,
        accountForEligibility: Bool,
        isOpenBankingEnabled: Bool
    ) -> [PaymentMethodType] {
        filter { method in
            switch method {
            case .account(let data):
                return data.topLimit.isPositive
                    && data.topLimit.currency == currentWalletCurrency
            case .suggested(let paymentMethod):
                switch paymentMethod.type {
                case .bankAccount:
                    return false // this method is not supported
                case .bankTransfer:
                    let isFiatSupported = paymentMethod.fiatCurrency == currentWalletCurrency
                    return accountForEligibility ? (paymentMethod.isEligible && isFiatSupported) : isFiatSupported
                case .funds(let currency):
                    guard accountForEligibility else {
                        return currency == currentWalletCurrency.currencyType
                    }
                    return currency == currentWalletCurrency.currencyType && paymentMethod.isEligible
                case .card, .applePay:
                    return accountForEligibility ? paymentMethod.isEligible : true
                }
            case .card(let data):
                return data.state == .active
            case .linkedBank(let data) where !isOpenBankingEnabled && data.partner != .yodlee:
                return false
            case .applePay(let data):
                return data.state == .active
            case .linkedBank(let data):
                return data.state == .active && data.currency == currentWalletCurrency
            }
        }
    }
}
