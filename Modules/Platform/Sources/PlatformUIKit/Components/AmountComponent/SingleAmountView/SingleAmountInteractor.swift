// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

public final class SingleAmountInteractor: AmountViewInteracting {
    // MARK: - Properties

    public let effect: Observable<AmountInteractorEffect> = .just(.none)
    public let activeInput: Observable<ActiveAmountInput>

    /// The state of the component
    public let stateRelay = BehaviorRelay<AmountInteractorState>(value: .validInput(.none))
    public var state: Observable<AmountInteractorState> {
        stateRelay.asObservable()
            .share(replay: 1, scope: .whileConnected)
    }

    public let auxiliaryButtonTappedRelay = PublishRelay<Void>()
    public let auxiliaryViewEnabledRelay = PublishRelay<Bool>()

    /// Streams the amount of `MoneyValue`
    public let amount: Observable<MoneyValue>

    public var rawAmount: Observable<MoneyValue> {
        amount
    }

    public let currencyInteractor: InputAmountLabelInteractor
    public let inputCurrency: Currency

    /// This interactor doesn't support min/max
    public var minAmountSelected: Observable<Void> = .never()
    public var maxAmountSelected: Observable<Void> = .never()

    /// This interactor does not support selecting a recurring buy frequency
    public var recurringBuyFrequencySelected: Observable<Void> = .never()

    // MARK: - Private

    private let currencyService: CurrencyServiceAPI

    private let disposeBag = DisposeBag()

    public init(
        currencyService: CurrencyServiceAPI,
        inputCurrency: Currency
    ) {
        self.activeInput = .just(inputCurrency.isFiatCurrency ? .fiat : .crypto)
        self.currencyService = currencyService
        self.inputCurrency = inputCurrency
        self.currencyInteractor = InputAmountLabelInteractor(currency: inputCurrency)

        self.amount = currencyInteractor
            .scanner
            .input
            .compactMap { [inputCurrency] input -> MoneyValue? in
                let amount = input.isEmpty || input.isPlaceholderZero ? "0" : input.amount
                return MoneyValue.create(major: amount, currency: inputCurrency.currencyType)
            }
            .share(replay: 1, scope: .whileConnected)
    }

    public func connect(input: Driver<AmountInteractorInput>) -> Driver<AmountInteractorState> {
        // Input Actions
        input.map(\.toInputScannerAction)
            .asObservable()
            .bindAndCatch(to: currencyInteractor.scanner.actionRelay)
            .disposed(by: disposeBag)

        state
            .map(\.toValidationState)
            .bindAndCatch(to: currencyInteractor.interactor.stateRelay)
            .disposed(by: disposeBag)

        return state
            .asDriver(onErrorJustReturn: .validInput(.none))
    }

    public func set(amount: String) {
        currencyInteractor.scanner
            .rawInputRelay
            .accept(amount)
    }

    public func set(amount: MoneyValue) {
        currencyInteractor
            .scanner
            .reset(to: amount)
    }

    public func set(auxiliaryViewEnabled: Bool) {
        auxiliaryViewEnabledRelay.accept(auxiliaryViewEnabled)
    }

    // There is no available balance view for the deposit flow so this will never publish anything
    // It is here to satisfy the protocol
    private let availableBalanceViewSelectedRelay = PublishRelay<AvailableBalanceDetails>()
    public var availableBalanceViewSelected: Observable<AvailableBalanceDetails> {
        availableBalanceViewSelectedRelay.asObservable()
    }
}

extension AmountInteractorInput {
    internal var toInputScannerAction: MoneyValueInputScanner.Action {
        switch self {
        case .insert(let value):
            return .insert(value)
        case .remove:
            return .remove
        }
    }
}
