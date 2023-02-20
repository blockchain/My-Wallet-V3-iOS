// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MoneyKit
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

/// The interface for the interactors behind all `AmountViewable` views
/// in the `Enter Amount` screen.
public protocol AmountViewInteracting {

    /// Current amount entered.
    var amount: Observable<MoneyValue> { get }

    /// The current input type (fiat or crypto)
    var activeInput: Observable<ActiveAmountInput> { get }

    /// The current input type (fiat or crypto)
    var rawAmount: Observable<MoneyValue> { get }

    /// If there's an error, an effect is returned. Currently
    /// only used to show an alert.
    var effect: Observable<AmountInteractorEffect> { get }

    /// The state of the interactor
    var stateRelay: BehaviorRelay<AmountInteractorState> { get }

    /// A relay responsible for accepting taps from the amount view's auxiliary button
    var auxiliaryButtonTappedRelay: PublishRelay<Void> { get }

    /// API for connecting user inputs and deriving a state of the interactor
    /// - Parameter input: Can be inserting or removing a character
    func connect(input: Driver<AmountInteractorInput>) -> Driver<AmountInteractorState>

    /// Setting the amount entered. Used for sending the `Max`
    /// - Parameter amount: `MoneyValue`
    func set(amount: MoneyValue)

    /// Setting the amount entered. Used for sending the `Max`
    /// - Parameter amount: `String`
    func set(amount: String)

    /// Sets the amount that the user is able to utilize in a given transaction.
    /// This is not the same as their balance. It often times takes into account the
    /// users balance, fees, as well as limits on their account.
    /// This is used when calculating quickfill amounts.
    /// - Parameter amount: `MoneyValue`
    func setActionableAmount(_ amount: MoneyValue)

    /// The total balance for a given account.
    /// For PKW this is often more than the available balance.
    /// This is used when displaying the `AvailableBalanceDetailView`
    /// - Parameter amount: `MoneyValue`
    func setAccountBalance(_ amount: MoneyValue)

    /// The transactionfee that the user is liable for for a given transaction.
    /// This is used when displaying the `AvailableBalanceDetailView`
    /// - Parameter amount: `MoneyValue`
    func setTransactionFeeAmount(_ amount: MoneyValue)

    /// Whether or not the transaction uses a `FeeLevel` of `.none`
    /// This is used when displaying the `AvailableBalanceDetailView`
    /// - Parameter isTxFeeLess: `Bool`
    func updateTxFeeLessState(_ isTxFeeLess: Bool)

    /// Sets the amount that the user is able to utilize in a given transaction.
    /// This is not the same as their balance. It often times takes into account the
    /// users balance, fees, as well as limits on their account.
    /// This is used when calculating quickfill amounts.
    /// - Parameter amount: `MoneyValue`
    func availableBalanceViewTapped()

    /// Toggles the auxiliary view on or off.
    /// When disabled, the auxiliary view doesn't show up on error states.
    /// Instead, the amount view displays the amount in a different style (e.g - red text).
    func set(auxiliaryViewEnabled: Bool)

    /// Called when the user taps the recurring buy frequency button in the buy flow
    func recurringBuyButtonTapped()

    var auxiliaryViewEnabledRelay: PublishRelay<Bool> { get }

    var minAmountSelected: Observable<Void> { get }

    var maxAmountSelected: Observable<Void> { get }

    var recurringBuyFrequencySelected: Observable<Void> { get }

    /// When the `AvailableBalanceView` is tapped.
    /// Once tapped the `AvailableBalanceDetailView` is shown.
    var availableBalanceViewSelected: Observable<AvailableBalanceDetails> { get }
}

extension AmountViewInteracting {
    public var availableBalanceViewSelected: Observable<AvailableBalanceDetails> {
        unimplemented("Only implemented in AmountViewInteractor")
    }

    public func availableBalanceViewTapped() {
        unimplemented("Only implemented in AmountViewInteractor")
    }

    public func setActionableAmount(_ amount: MoneyValue) {
        unimplemented("Only implemented in AmountViewInteractor")
    }

    public func setTransactionFeeAmount(_ amount: MoneyValue) {
        unimplemented("Only implemented in AmountViewInteractor")
    }

    public func setAccountBalance(_ amount: MoneyValue) {
        unimplemented("Only implemented in AmountViewInteractor")
    }

    public func updateTxFeeLessState(_ isTxFeeLess: Bool) {
        unimplemented("Only implemented in AmountViewInteractor")
    }

    public func recurringBuyButtonTapped() {
        unimplemented("Only implemented in AmountViewInteractor")
    }
}

public struct AvailableBalanceDetails {
    public let balance: AnyPublisher<FiatValue, Never>
    public let availableBalance: AnyPublisher<FiatValue, Never>
    public let fee: AnyPublisher<FiatValue, Never>
    public let transactionIsFeeLess: AnyPublisher<Bool, Never>
}
