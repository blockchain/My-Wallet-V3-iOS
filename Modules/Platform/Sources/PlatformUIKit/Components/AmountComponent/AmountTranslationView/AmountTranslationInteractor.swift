// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import MoneyKit
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

public final class AmountTranslationInteractor: AmountViewInteracting {

    // MARK: - Properties

    /// Fiat interactor
    public let fiatInteractor: InputAmountLabelInteractor

    /// Crypto interactor
    public let cryptoInteractor: InputAmountLabelInteractor

    var currentInteractor: Single<InputAmountLabelInteractor> {
        activeInput
            .map(weak: self) { (self, activeInput) in
                switch activeInput {
                case .fiat:
                    return self.fiatInteractor
                case .crypto:
                    return self.cryptoInteractor
                }
            }
            .take(1)
            .asSingle()
    }

    /// The state of the component
    public let stateRelay = BehaviorRelay<AmountInteractorState>(value: .validInput(.none))
    public var state: Observable<AmountInteractorState> {
        stateRelay.asObservable()
    }

    public var effect: Observable<AmountInteractorEffect> {
        effectRelay
            .asObservable()
            .distinctUntilChanged()
            .subscribe(on: MainScheduler.asyncInstance)
    }

    /// The active input relay
    public let activeInputRelay: BehaviorRelay<ActiveAmountInput>

    /// A relay responsible for accepting deletion events for the active input
    public let deleteLastRelay = PublishRelay<Void>()

    /// A relay responsible for appending new characters to the active input
    public let appendNewRelay = PublishRelay<Character>()

    /// A relay responsible for accepting taps from the amount view's auxiliary button
    public let auxiliaryButtonTappedRelay = PublishRelay<Void>()

    public let auxiliaryViewEnabledRelay = PublishRelay<Bool>()

    /// The active input - streams distinct elements of `AmountInteractorActiveInput`
    public var activeInput: Observable<ActiveAmountInput> {
        activeInputRelay
            .asObservable()
            .distinctUntilChanged()
            .subscribe(on: MainScheduler.asyncInstance)
    }

    /// Input injection relay - allow any client of the component to inject number as a `Decimal` type
    public let inputInjectionRelay = PublishRelay<Decimal>()

    /// Streams the amount as `FiatValue`
    public var fiatAmount: Observable<MoneyValue> {
        fiatAmountRelay.asObservable()
    }

    /// Streams the amount as `CryptoValue`
    public var cryptoAmount: Observable<MoneyValue> {
        cryptoAmountRelay.asObservable()
    }

    /// Streams the amount depending on the `ActiveAmountInput` type.
    public var amount: Observable<MoneyValue> {
        Observable
            .combineLatest(cryptoAmount, fiatAmount, activeInput)
            .map { (crypto: $0.0, fiat: $0.1, input: $0.2) }
            .map { (crypto: MoneyValue, fiat: MoneyValue, input: ActiveAmountInput) -> MoneyValue in
                switch input {
                case .crypto:
                    return crypto
                case .fiat:
                    return fiat
                }
            }
    }

    public var accountBalancePublisher: AnyPublisher<FiatValue, Never> {
        accountBalanceFiatValueRelay
            .asObservable()
            .asPublisher()
            .ignoreFailure()
            .eraseToAnyPublisher()
    }

    public var transactionIsFeeLessPublisher: AnyPublisher<Bool, Never> {
        transactionIsFeeLessRelay
            .asObservable()
            .asPublisher()
            .ignoreFailure()
            .eraseToAnyPublisher()
    }

    public var transactionFeePublisher: AnyPublisher<FiatValue, Never> {
        transactionFeeFiatValueRelay
            .asObservable()
            .asPublisher()
            .ignoreFailure()
            .eraseToAnyPublisher()
    }

    public var maxLimitPublisher: AnyPublisher<FiatValue, Never> {
        maxActionableFiatAmountRelay
            .asObservable()
            .asPublisher()
            .ignoreFailure()
            .eraseToAnyPublisher()
    }

    public var lastPurchasePublisher: AnyPublisher<FiatValue, Never> {
        let amount = app.publisher(
            for: blockchain.ux.transaction.source.target.previous.input.amount,
            as: BigInt.self
        )
        .map(\.value)
        let currency = app.publisher(
            for: blockchain.ux.transaction.source.target.previous.input.currency.code,
            as: FiatCurrency.self
        )
        .map(\.value)
        let tradingCurrency = app.publisher(
            for: blockchain.user.currency.preferred.fiat.trading.currency,
            as: FiatCurrency.self
        )
        .compactMap(\.value)
        return amount.combineLatest(currency, tradingCurrency)
            .map { amount, currency, tradingCurrency in
                if let amount, let currency {
                    return FiatValue.create(minor: amount, currency: currency)
                } else {
                    // If there's no previous purchase default to 50.00 of trading currency
                    return FiatValue.create(majorBigInt: 50, currency: tradingCurrency)
                }
            }
            .eraseToAnyPublisher()
    }

    /// The amount as `FiatValue`
    private let fiatAmountRelay: BehaviorRelay<MoneyValue>

    /// The amount as `CryptoValue`
    private let cryptoAmountRelay: BehaviorRelay<MoneyValue>

    /// The maximum amount of fiat the user can use for the transaction.
    private let maxActionableFiatAmountRelay: BehaviorRelay<FiatValue>

    /// The balance of the `BlockchainAccount`
    private let accountBalanceFiatValueRelay: BehaviorRelay<FiatValue>

    /// The transaction fee
    private let transactionFeeFiatValueRelay: BehaviorRelay<FiatValue>

    /// If the transaction FeeLevel is none
    private let transactionIsFeeLessRelay: BehaviorRelay<Bool>

    /// A relay that streams an effect, such as a failure
    private let effectRelay = BehaviorRelay<AmountInteractorEffect>(value: .none)

    // MARK: - Injected

    private let app: AppProtocol
    private let fiatCurrencyClosure: () -> Observable<FiatCurrency>
    private let cryptoCurrencyService: CryptoCurrencyServiceAPI
    private let priceProvider: AmountTranslationPriceProviding

    // MARK: - Accessors

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        fiatCurrencyClosure: @escaping () -> Observable<FiatCurrency>,
        cryptoCurrencyService: CryptoCurrencyServiceAPI,
        priceProvider: AmountTranslationPriceProviding,
        defaultFiatCurrency: FiatCurrency = .default,
        app: AppProtocol,
        defaultCryptoCurrency: CryptoCurrency,
        initialActiveInput: ActiveAmountInput
    ) {
        self.app = app
        self.activeInputRelay = BehaviorRelay(value: initialActiveInput)
        self.maxActionableFiatAmountRelay = BehaviorRelay(value: .zero(currency: defaultFiatCurrency))
        self.accountBalanceFiatValueRelay = BehaviorRelay(value: .zero(currency: defaultFiatCurrency))
        self.transactionFeeFiatValueRelay = BehaviorRelay(value: .zero(currency: defaultFiatCurrency))
        self.cryptoAmountRelay = BehaviorRelay(value: .zero(currency: defaultCryptoCurrency))
        self.fiatInteractor = InputAmountLabelInteractor(currency: defaultFiatCurrency)
        self.cryptoInteractor = InputAmountLabelInteractor(currency: defaultCryptoCurrency)
        self.transactionIsFeeLessRelay = BehaviorRelay(value: true)
        self.fiatCurrencyClosure = fiatCurrencyClosure
        self.cryptoCurrencyService = cryptoCurrencyService
        self.priceProvider = priceProvider
        self.fiatAmountRelay = BehaviorRelay<MoneyValue>(
            value: .zero(currency: defaultFiatCurrency)
        )

        // Currency Change - upon selection of a new fiat or crypto currency,
        // take the current input amount and based on that and the new currency
        // modify the fiat / crypto value

        // Fiat changes affect crypto
        let fallibleFiatCurrency = fiatCurrencyClosure()
            .map { $0 as Currency }

        let fallibleCryptoCurrency = cryptoCurrencyService.cryptoCurrencyObservable
            .map { $0 as Currency }

        let fiatCurrency = fallibleFiatCurrency
            .catch { _ -> Observable<Currency> in
                .empty()
            }
            .share(replay: 1, scope: .whileConnected)

        let cryptoCurrency = fallibleCryptoCurrency
            .catch { _ -> Observable<Currency> in
                .empty()
            }
            .share(replay: 1, scope: .whileConnected)

        fiatCurrency
            .bindAndCatch(to: fiatInteractor.interactor.currencyRelay)
            .disposed(by: disposeBag)

        cryptoCurrency
            .bindAndCatch(to: cryptoInteractor.interactor.currencyRelay)
            .disposed(by: disposeBag)

        // We need to keep any currency selection changes up to date with the input values
        // and eventually update the `cryptoAmountRelay` and `fiatAmountRelay`
        let currenciesMerged = Observable.merge(fallibleFiatCurrency, fallibleCryptoCurrency)
            .consumeErrorToEffect(on: self)
            .share(replay: 1, scope: .whileConnected)

        // Make fiat amount zero after any currency change
        currenciesMerged
            .mapToVoid()
            .map { "" }
            .bindAndCatch(to: fiatInteractor.scanner.rawInputRelay, cryptoInteractor.scanner.rawInputRelay)
            .disposed(by: disposeBag)

        // Bind of the edit values to the scanner depending on the currently edited currency type
        let pairFromFiatInput = currenciesMerged
            .flatMap(weak: self) { (self, _) -> Observable<MoneyValueInputScanner.Input> in
                self.fiatInteractor.scanner.input
            }
            .flatMap(weak: self) { (self, input) in
                self.activeInput
                    .take(1)
                    .map { (activeInputType: $0, input: input) }
            }
            // Only when the fiat is under focus
            .filter { $0.activeInputType == .fiat }
            // Get the value
            .map(\.input)
            .flatMapLatest(weak: self) { (self, value) -> Observable<MoneyValuePair> in
                self.pairFromFiatInput(amount: value.amount).asObservable()
            }
            .consumeErrorToEffect(on: self)

        let pairFromCryptoInput = currenciesMerged
            .flatMap(weak: self) { (self, _) -> Observable<MoneyValueInputScanner.Input> in
                self.cryptoInteractor.scanner.input
            }
            .flatMap(weak: self) { (self, input) in
                self.activeInput
                    .take(1)
                    .map { (activeInputType: $0, input: input) }
            }
            .filter { $0.activeInputType == .crypto }
            .map(\.input)
            .flatMapLatest(weak: self) { (self, value) -> Observable<MoneyValuePair> in
                self.pairFromCryptoInput(amount: value.amount).asObservable()
            }
            .consumeErrorToEffect(on: self)

        // Merge the output of the scanner from edited amount to the other scanner input relay

        pairFromFiatInput
            .map(\.quote)
            .map(\.displayMajorValue)
            .map { "\($0)" }
            .withLatestFrom(activeInput) { ($0, $1) }
            .filter { _, active in active == .fiat }
            .map(\.0)
            .bindAndCatch(to: cryptoInteractor.scanner.rawInputRelay)
            .disposed(by: disposeBag)

        pairFromCryptoInput
            .map(\.quote)
            .map(\.displayMajorValue)
            .map { "\($0)" }
            .withLatestFrom(activeInput) { ($0, $1) }
            .filter { _, active in active == .crypto }
            .map(\.0)
            .bindAndCatch(to: fiatInteractor.scanner.rawInputRelay)
            .disposed(by: disposeBag)

        let anyPair = Observable
            .merge(
                pairFromCryptoInput,
                pairFromFiatInput
            )
            .share(replay: 1)

        anyPair
            .bindAndCatch(weak: self) { (self, value) in
                switch value.base.currency {
                case .crypto:
                    self.cryptoAmountRelay.accept(value.base)
                    self.fiatAmountRelay.accept(value.quote)
                case .fiat:
                    self.fiatAmountRelay.accept(value.base)
                    self.cryptoAmountRelay.accept(value.quote)
                }
            }
            .disposed(by: disposeBag)

        // Bind deletion events

        let deleteAction = deleteLastRelay
            .withLatestFrom(activeInput)
            .share(replay: 1)

        deleteAction
            .filter { $0 == .fiat }
            .mapToVoid()
            .map { MoneyValueInputScanner.Action.remove }
            .bindAndCatch(to: fiatInteractor.scanner.actionRelay)
            .disposed(by: disposeBag)

        deleteAction
            .filter { $0 == .crypto }
            .mapToVoid()
            .map { MoneyValueInputScanner.Action.remove }
            .bindAndCatch(to: cryptoInteractor.scanner.actionRelay)
            .disposed(by: disposeBag)

        // Bind insertion events

        let insertAction = appendNewRelay
            .map { MoneyValueInputScanner.Action.insert($0) }
            .flatMap { [activeInput] action in
                activeInput
                    .take(1)
                    .map { (activeInputType: $0, action: action) }
            }
            .share(replay: 1)

        insertAction
            .filter { $0.0 == .fiat }
            .map(\.1)
            .bindAndCatch(to: fiatInteractor.scanner.actionRelay)
            .disposed(by: disposeBag)

        insertAction
            .filter { $0.0 == .crypto }
            .map(\.1)
            .bindAndCatch(to: cryptoInteractor.scanner.actionRelay)
            .disposed(by: disposeBag)

        state
            .map(\.toValidationState)
            .bindAndCatch(to: fiatInteractor.interactor.stateRelay, cryptoInteractor.interactor.stateRelay)
            .disposed(by: disposeBag)

        let inputInjectionAction = inputInjectionRelay
            .flatMap(weak: self) { (self, input) in
                self.activeInput
                    .take(1)
                    .map { (activeInputType: $0, action: input) }
            }
            .share(replay: 1)

        inputInjectionAction
            .filter { $0.0 == .fiat }
            .map(\.1)
            .map { .init(decimal: $0) }
            .bindAndCatch(to: fiatInteractor.scanner.internalInputRelay)
            .disposed(by: disposeBag)

        inputInjectionAction
            .filter { $0.0 == .crypto }
            .map(\.1)
            .map { .init(decimal: $0) }
            .bindAndCatch(to: cryptoInteractor.scanner.internalInputRelay)
            .disposed(by: disposeBag)
    }

    public func connect(input: Driver<AmountInteractorInput>) -> Driver<AmountInteractorState> {
        // Input Actions
        input
            .compactMap(\.character)
            .asObservable()
            .bindAndCatch(to: appendNewRelay)
            .disposed(by: disposeBag)

        input
            .filter { $0.character == nil }
            .asObservable()
            .mapToVoid()
            .bindAndCatch(to: deleteLastRelay)
            .disposed(by: disposeBag)

        return state
            .asDriver(onErrorJustReturn: .validInput(.none))
    }

    public func setActionableAmount(_ amount: MoneyValue) {
        if let fiatValue = amount.fiatValue {
            maxActionableFiatAmountRelay.accept(fiatValue)
        }
        if let cryptoValue = amount.cryptoValue {
            pairFromCryptoInput(
                amount: cryptoValue.displayString
            )
            .map(\.quote)
            .subscribe { [maxActionableFiatAmountRelay] moneyValue in
                guard let value = moneyValue.fiatValue else { return }
                maxActionableFiatAmountRelay.accept(value)
            }
            .disposed(by: disposeBag)
        }
    }

    public func setAccountBalance(_ amount: MoneyValue) {
        if let fiatValue = amount.fiatValue {
            accountBalanceFiatValueRelay.accept(fiatValue)
        }
        if let cryptoValue = amount.cryptoValue {
            pairFromCryptoInput(
                amount: cryptoValue.displayString
            )
            .map(\.quote)
            .subscribe { [accountBalanceFiatValueRelay] moneyValue in
                guard let value = moneyValue.fiatValue else { return }
                accountBalanceFiatValueRelay.accept(value)
            }
            .disposed(by: disposeBag)
        }
    }

    public func updateTxFeeLessState(_ isTxFeeLess: Bool) {
        transactionIsFeeLessRelay.accept(isTxFeeLess)
    }

    public func setTransactionFeeAmount(_ amount: MoneyValue) {
        if let fiatValue = amount.fiatValue {
            transactionFeeFiatValueRelay.accept(fiatValue)
        }
        if let cryptoValue = amount.cryptoValue {
            pairFromCryptoInput(
                amount: cryptoValue.displayString
            )
            .map(\.quote)
            .subscribe { [transactionFeeFiatValueRelay] moneyValue in
                guard let value = moneyValue.fiatValue else { return }
                transactionFeeFiatValueRelay.accept(value)
            }
            .disposed(by: disposeBag)
        }
    }

    public func set(amount: String) {
        currentInteractor
            .asObservable()
            .bind { interactor in
                interactor.scanner.rawInputRelay.accept(amount)
            }
            .disposed(by: disposeBag)
    }

    public func set(amount: MoneyValue) {
        invertInputIfNeeded(for: amount)
            .andThen(currentInteractor)
            .subscribe { interactor in
                interactor.scanner.reset(to: amount)
            }
            .disposed(by: disposeBag)
    }

    private let minAmountSelectedRelay = PublishRelay<Void>()
    public var minAmountSelected: Observable<Void> {
        minAmountSelectedRelay.asObservable()
    }

    public func set(minAmount: MoneyValue) {
        minAmountSelectedRelay.accept(())
        set(amount: minAmount)
    }

    private let availableBalanceViewSelectedRelay = PublishRelay<AvailableBalanceDetails>()
    public var availableBalanceViewSelected: Observable<AvailableBalanceDetails> {
        availableBalanceViewSelectedRelay.asObservable()
    }

    private let recurringBuyFrequencySelectedRelay = PublishRelay<Void>()
    public var recurringBuyFrequencySelected: Observable<Void> {
        recurringBuyFrequencySelectedRelay
            .asObservable()
    }

    private let maxAmountSelectedRelay = PublishRelay<Void>()
    public var maxAmountSelected: Observable<Void> {
        maxAmountSelectedRelay
            .asObservable()
    }

    public func availableBalanceViewTapped() {
        availableBalanceViewSelectedRelay.accept(
            .init(
                balance: accountBalancePublisher,
                availableBalance: maxLimitPublisher,
                fee: transactionFeePublisher,
                transactionIsFeeLess: transactionIsFeeLessPublisher
            )
        )
    }

    public func set(maxAmount: MoneyValue) {
        maxAmountSelectedRelay.accept(())
        set(amount: maxAmount)
    }

    public func set(auxiliaryViewEnabled: Bool) {
        auxiliaryViewEnabledRelay.accept(auxiliaryViewEnabled)
    }

    public func recurringBuyButtonTapped() {
        recurringBuyFrequencySelectedRelay.accept(())
    }

    private func invertInputIfNeeded(for amount: MoneyValue) -> Completable {
        activeInput.take(1)
            .asSingle()
            .flatMapCompletable(weak: self) { (self, activeInput) -> Completable in
                switch (activeInput, amount.isFiat) {
                case (.fiat, true), (.crypto, false):
                    return .empty()
                case (.fiat, false), (.crypto, true):
                    return self.invertInput(from: activeInput)
                }
            }
    }

    private func invertInput(from activeInput: ActiveAmountInput) -> Completable {
        Single.just(activeInput)
            .map(\.inverted)
            .observe(on: MainScheduler.asyncInstance)
            .do(onSuccess: activeInputRelay.accept)
            .asCompletable()
    }

    private func pairFromFiatInput(amount: String) -> Single<MoneyValuePair> {
        Single
            .zip(
                cryptoCurrencyService.cryptoCurrency,
                fiatCurrencyClosure()
                    .take(1)
                    .asSingle()
            )
            .flatMap(weak: self) { (self, currencies) -> Single<MoneyValuePair> in
                let (cryptoCurrency, fiatCurrency) = currencies
                return self.priceProvider
                    .pairFromFiatInput(
                        cryptoCurrency: cryptoCurrency,
                        fiatCurrency: fiatCurrency,
                        amount: amount
                    )
            }
    }

    private func pairFromCryptoInput(amount: String) -> Single<MoneyValuePair> {
        Single
            .zip(
                cryptoCurrencyService.cryptoCurrency,
                fiatCurrencyClosure()
                    .take(1)
                    .asSingle()
            )
            .flatMap(weak: self) { (self, currencies) -> Single<MoneyValuePair> in
                let (cryptoCurrency, fiatCurrency) = currencies
                return self.priceProvider
                    .pairFromCryptoInput(
                        cryptoCurrency: cryptoCurrency,
                        fiatCurrency: fiatCurrency,
                        amount: amount
                    )
            }
    }

    /// Provides a mechanism to handle an error as produced by an observable stream
    ///
    /// - Parameter error: An `Error` object describing the issue
    fileprivate func handleCurrency(error: Error) {
        if case .none = effectRelay.value {
            effectRelay.accept(.failure(error: error))
        }
    }
}

extension AmountInteractorState {
    internal var toValidationState: ValidationState {
        switch self {
        case .validInput:
            return .valid
        case .invalidInput:
            return .invalid
        }
    }
}

extension AmountInteractorEffect: Equatable {
    public static func == (lhs: AmountInteractorEffect, rhs: AmountInteractorEffect) -> Bool {
        switch (lhs, rhs) {
        case (.failure, .failure):
            return true
        case (.none, .none):
            return true
        default:
            return false
        }
    }
}

extension Observable {

    fileprivate func consumeErrorToEffect(on handler: AmountTranslationInteractor) -> Observable<Element> {
        self
            .do(
                onError: { [weak handler] error in
                    handler?.handleCurrency(error: error)
                }
            )
            .catch { _ in
                Observable<Element>.empty()
            }
    }
}
