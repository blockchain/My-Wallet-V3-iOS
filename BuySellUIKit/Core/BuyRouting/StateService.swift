//
//  Repository.swift
//  Blockchain
//
//  Created by Daniel Huri on 04/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import BuySellKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

public final class StateService: StateServiceAPI {

    // MARK: - Types
            
    /// Comprise all the states so far in the current Simple-Buy session
    struct States {
        
        /// The actual state of the flow
        let current: State
        
        /// The previous states sorted chronologically
        let previous: [State]
        
        /// A computed inactive state
        static var inactive: States {
            States(current: .inactive, previous: [])
        }
        
        /// Maps the instance of `States` into a new instance where the appended
        /// state is the current
        func states(byAppending state: State) -> States {
            States(
                current: state,
                previous: previous + [current]
            )
        }

        /// Maps the instance of `States` into a new instance where the last
        /// state is trimmed off. In case `previous` is an empty array, `current` will be
        /// `.inactive`.
        func statesByRemovingLast() -> States {
            States(
                current: previous.last ?? .inactive,
                previous: previous.dropLast()
            )
        }
    }
    
    /// Marks a past or present state in the state-machine
    public enum State {
        
        /// First time the user performs the simple buy flow
        case intro
        
        /// Fiat Selection
        case selectFiat
        
        /// Fiat selection is not supported in SB
        case unsupportedFiat(FiatCurrency)
                        
        /// In the middle of the buy screen
        case buy
        
        /// Change your fiat type from the `Buy` screen.
        /// Shows only supported `fiat` types
        case changeFiat
        
        /// The user wants to view his payment method types
        case paymentMethods
        
        /// The user would enter add-card flow before checking out
        case addCard(CheckoutData)
        
        /// During KYC process
        case kycBeforeCheckout(CheckoutData)
        
        /// KYC
        case kyc
        
        /// Show a given URL
        case showURL(URL)
        
        /// Pending KYC approval
        case pendingKycApproval(CheckoutData)
        
        /// Ineligible
        case ineligible
        
        /// The user is checking-out
        case checkout(CheckoutData)
        
        /// The user authorized his bank wire
        case bankTransferDetails(CheckoutData)

        /// Funds transfer details
        case fundsTransferDetails(currency: CurrencyType, isOriginPaymentMethods: Bool, isOriginDeposit: Bool)
        
        /// The user authorized his card payment and should now be referred to partner
        case authorizeCard(order: OrderDetails)

        /// The user may cancel their transfer
        case transferCancellation(CheckoutData)

        /// The user has a pending order
        case pendingOrderDetails(CheckoutData)

        /// Purchase completed
        case pendingOrderCompleted(orderDetails: OrderDetails)

        /// The user will be taken to link a bank flow
        case linkBank
        
        /// Inactive state - no buy flow is performed at the moment
        case inactive
        
        var isPaymentMethods: Bool {
            switch self {
            case .paymentMethods:
                return true
            default:
                return false
            }
        }
    }
    
    public enum Action {
        case next(to: State)
        case previous(from: State)
        case dismiss
    }
        
    // MARK: - Properties

    var states: Observable<States> {
        statesRelay.asObservable()
    }
    
    var currentState: Observable<StateService.State> {
        states.map { $0.current }
    }
    
    public var action: Observable<Action> {
        actionRelay
            .observeOn(MainScheduler.instance)
    }
    
    public let nextRelay = PublishRelay<Void>()
    public let previousRelay = PublishRelay<Void>()

    public let cache: EventCache
   
    private let supportedPairsInteractor: SupportedPairsInteractorServiceAPI
    private let paymentAccountService: PaymentAccountServiceAPI
    private let pendingOrderDetailsService: PendingOrderDetailsServiceAPI
    private let kycTiersService: KYCTiersServiceAPI
    private let statesRelay = BehaviorRelay<States>(value: .inactive)
    private let actionRelay = PublishRelay<Action>()
    private let loader: LoadingViewPresenting
    private let alert: AlertViewPresenterAPI
    private let messageRecorder: MessageRecording
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(supportedPairsInteractor: SupportedPairsInteractorServiceAPI = resolve(),
                paymentAccountService: PaymentAccountServiceAPI = resolve(),
                pendingOrderDetailsService: PendingOrderDetailsServiceAPI = resolve(),
                kycTiersService: KYCTiersServiceAPI = resolve(),
                cache: EventCache = resolve(),
                loader: LoadingViewPresenting = resolve(),
                alert: AlertViewPresenterAPI = resolve(),
                messageRecorder: MessageRecording = resolve()) {
        self.supportedPairsInteractor = supportedPairsInteractor
        self.paymentAccountService = paymentAccountService
        self.pendingOrderDetailsService = pendingOrderDetailsService
        self.kycTiersService = kycTiersService
        self.cache = cache
        self.loader = loader
        self.alert = alert
        self.messageRecorder = messageRecorder
        
        nextRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in self.next() }
            .disposed(by: disposeBag)
        
        previousRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in self.previous() }
            .disposed(by: disposeBag)
    }
    
    public func cardRoutingInteractor(with checkoutData: CheckoutData) -> CardRouterInteractor {
        let interactor = CardRouterInteractor()
        interactor.completionCardData
            .bindAndCatch(weak: self) { (self, cardData) in
                let checkoutData = checkoutData.checkoutData(byAppending: cardData)
                self.previous()
                self.nextFromBuyCrypto(with: checkoutData)
            }
            .disposed(by: disposeBag)
        
        interactor.cancellation
            .bindAndCatch(weak: self) { (self) in
                self.previous()
            }
            .disposed(by: disposeBag)

        return interactor
    }
        
    // TODO: Look into reactive state machine
    private func next() {
        let states = statesRelay.value
        messageRecorder.record("StateService: next: \(states.debugDescription)")
        let state: State
        switch states.current {
        case .inactive:
            startFlow()
        case .intro:
            state = .selectFiat
            apply(
                action: .next(to: state),
                states: self.states(byAppending: state)
            )
        case .kycBeforeCheckout(let data):
            state = .pendingKycApproval(data)
            apply(
                action: .next(to: state),
                states: self.states(byAppending: state)
            )
        case .pendingKycApproval(let data):
            // After KYC - add card if necessary or go to checkout for bank transfer
            switch data.order.paymentMethod {
            case .bankAccount:
                state = .checkout(data)
            case .card:
                state = .addCard(data)
            case .funds:
                state = .fundsTransferDetails(
                    currency: data.order.inputValue.currencyType,
                    isOriginPaymentMethods: false,
                    isOriginDeposit: false
                )
            case .bankTransfer:
                state = .checkout(data)
            }
            apply(
                action: .next(to: state),
                states: self.states(byAppending: state)
            )
        case .bankTransferDetails,
             .fundsTransferDetails,
             .pendingOrderDetails,
             .transferCancellation,
             .unsupportedFiat,
             .showURL,
             .changeFiat,
             .linkBank:
            state = .inactive
            apply(
                action: .dismiss,
                states: self.states(byAppending: state)
            )
        case .kyc:
            statesRelay.accept(statesByRemovingLast())
        case .buy, .checkout, .paymentMethods, .selectFiat, .addCard, .authorizeCard, .pendingOrderCompleted, .ineligible:
            fatalError("\(#function) was called with unhandled state: \(states.debugDescription).")
        }
    }
    
    private func previous() {
        let last = statesRelay.value.current
        let states = statesByRemovingLast()
        let current = states.current
        let action: Action
        switch (last, current) {
        /// Dismiss in case the current state is `inactive`.
        /// Dismiss in case the last state is `pendingKycApproval` (end user tapped the continue button)
        case (_, .inactive),
             (.pendingKycApproval, _),
             (.ineligible, _):
            action = .dismiss
        default:
            action = .previous(from: last)
        }
        apply(action: action, states: states)
    }
        
    private func startFlow() {
        let cache = self.cache
        let isFiatCurrencySupported: Single<Bool> = supportedPairsInteractor.pairs
            .take(1)
            .asSingle()
            .map { !$0.pairs.isEmpty }

        let isTier2Approved = kycTiersService
            .fetchTiers()
            .map { $0.isTier2Approved }
                
        Single
            .zip(
                pendingOrderDetailsService.pendingOrderDetails,
                isFiatCurrencySupported
            ) { (pendingOrderDetails: $0, isFiatCurrencySupported: $1) }
            .handleLoaderForLifecycle(
                loader: loader,
                style: .circle
            )
            .flatMap { data -> Single<State> in
                if let orderDetails = data.pendingOrderDetails {
                    let checkoutData = CheckoutData(order: orderDetails)
                    switch orderDetails.state {
                    /// If the order is in `pendingConfirmation` check if the user is tier two approved.
                    /// In case the user is KYCed: send the user to checkout to complete the order
                    /// In case the user has not KYCed yet: Go to the main buy screen to re-enter amount,
                    /// recreate the order, and then to KYC.
                    case .pendingConfirmation:
                        return isTier2Approved
                            .map { isTier2Approved in
                                // User must be GOLD to get to checkout
                                guard isTier2Approved else {
                                    return .buy
                                }
                                // If the order is card but payment method id is missing - navigate to the main amount screen
                                if checkoutData.isUnknownCardType || checkoutData.isUnknownBankTransfer {
                                    return .buy
                                }
                                // If this is not a Buy order - navigate to the main amount screen
                                guard checkoutData.order.isBuy else {
                                    return .buy
                                }
                                return .checkout(checkoutData)
                            }
                    default:
                        switch orderDetails.paymentMethod {
                        case .card:
                            if orderDetails.is3DSConfirmedCardOrder {
                                return .just(
                                    .pendingOrderCompleted(
                                        orderDetails: orderDetails
                                    )
                                )
                            } else {
                                return .just(.checkout(checkoutData))
                            }
                        case .bankTransfer:
                            return .just(.checkout(checkoutData))
                        case .bankAccount:
                            return .just(.pendingOrderDetails(checkoutData))
                        case .funds:
                            return .just(.pendingOrderDetails(checkoutData))
                        }
                    }
                } else {
                    if cache[.hasShownIntroScreen] {
                        return .just(data.isFiatCurrencySupported ? .buy : .selectFiat)
                    } else {
                        return .just(.intro)
                    }
                }
            }
            .subscribe(
                onSuccess: { [weak self] state in
                    guard let self = self else { return }
                    /// The user already has a pending order, so
                    /// mark the intro screen as `shown`.
                    switch state {
                    case .checkout, .pendingOrderDetails, .pendingOrderCompleted, .bankTransferDetails:
                        cache[.hasShownIntroScreen] = true
                    default:
                        break
                    }
                    
                    self.apply(
                        action: .next(to: state),
                        states: self.states(byAppending: state)
                    )
                },
                onError: { [weak alert] error in
                    alert?.error(in: nil, action: nil)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func apply(action: Action, states: States) {
        messageRecorder.record("StateService: apply: \(action) and \(states.debugDescription)")
        actionRelay.accept(action)
        statesRelay.accept(states)
        cache(state: states.current)
    }
    
    private func cache(state: State) {
        switch state {
        case .buy:
            cache[.hasShownBuyScreen] = true
        case .intro:
            cache[.hasShownIntroScreen] = true
        default:
            break
        }
    }
    
    private func statesByRemovingLast() -> States {
        messageRecorder.record("StateService: removing last: \(statesRelay.value.debugDescription)")
        return statesRelay.value.statesByRemovingLast()
    }
    
    private func states(byAppending state: State) -> States {
        messageRecorder.record("StateService: appending state: \(state.debugDescription) to \(statesRelay.value.debugDescription)")
        return statesRelay.value.states(byAppending: state)
    }
}

// MARK: - PaymentMethods

extension StateService {
    
    public func showFundsTransferDetails(for fiatCurrency: FiatCurrency, isOriginDeposit: Bool) {
        let currentState = statesRelay.value.current
        if currentState.isPaymentMethods {
            statesRelay.accept(statesByRemovingLast())
        }
        let states = self.states(
            byAppending: .fundsTransferDetails(
                currency: .fiat(fiatCurrency),
                isOriginPaymentMethods: currentState.isPaymentMethods,
                isOriginDeposit: isOriginDeposit
            )
        )
        apply(action: .next(to: states.current), states: states)
    }
}

// MARK: - ElibilityRelayAPI

extension StateService {
    
    public func ineligible(with currency: FiatCurrency) {
        let states = self.states(byAppending: .unsupportedFiat(currency))
        apply(action: .next(to: states.current), states: states)
    }
}

// MARK: - URLSelectionServiceAPI

extension StateService {
    public func show(url: URL) {
        let states = self.states(byAppending: .showURL(url))
        apply(action: .next(to: states.current), states: states)
    }
}

// MARK: - CheckoutServiceAPI

extension StateService {
    
    public func nextFromBuyCrypto(with checkoutData: CheckoutData) {
        let state: State
        switch checkoutData.order.paymentMethod {
        case .card where !checkoutData.isPaymentMethodFinalized:
            state = .addCard(checkoutData)
        case .bankTransfer where !checkoutData.isPaymentMethodFinalized:
            state = .linkBank
        default:
            state = .checkout(checkoutData)
        }

        let states = self.states(byAppending: state)
        apply(action: .next(to: states.current), states: states)
    }

    public func nextFromBankLinkSelection() {
        let states = self.states(byAppending: .linkBank)
        apply(action: .next(to: states.current), states: states)
    }
    
    public func kyc(with checkoutData: CheckoutData) {
        let states = self.states(byAppending: .kycBeforeCheckout(checkoutData))
        apply(action: .next(to: states.current), states: states)
    }

    public func kyc() {
        let currentState = statesRelay.value.current
        if currentState.isPaymentMethods {
            statesRelay.accept(statesByRemovingLast())
        }
        let states = self.states(byAppending: .kyc)
        apply(action: .next(to: states.current), states: states)
    }
    
    public func ineligible(with checkoutData: CheckoutData) {
        let states = self.states(byAppending: .pendingKycApproval(checkoutData))
        apply(action: .next(to: states.current), states: states)
    }
    
    public func ineligible() {
        let states = self.states(byAppending: .ineligible)
        apply(action: .next(to: states.current), states: states)
    }

    public func paymentMethods() {
        let states = self.states(byAppending: .paymentMethods)
        apply(action: .next(to: states.current), states: states)
    }
    
    public func changeCurrency() {
        let states = self.states(byAppending: .changeFiat)
        apply(action: .next(to: states.current), states: states)
    }

    public func bankTransferDetails(with checkoutData: CheckoutData) {
        let states = self.states(byAppending: .bankTransferDetails(checkoutData))
        apply(action: .next(to: states.current), states: states)
    }
}

// MARK: - CurrencySelectionServiceAPI

extension StateService {
    public func currencySelected() {
        let states = self.states(byAppending: .buy)
        apply(action: .next(to: states.current), states: states)
    }
    
    public func reselectCurrency() {
        previousRelay.accept(())
        let states = self.states(byAppending: .selectFiat)
        apply(action: .next(to: states.current), states: states)
    }
}

// MARK: - ConfirmCheckoutServiceAPI

extension StateService {
    public func confirmCheckout(with checkoutData: CheckoutData, isOrderNew: Bool) {
        let state: State
        let data = (checkoutData.order.paymentMethod, isOrderNew)
        switch data {
        case (.funds, true):
            state = .pendingOrderCompleted(
                orderDetails: checkoutData.order
            )
        case (.bankAccount, true):
            state = .bankTransferDetails(checkoutData)
        case (.bankTransfer, true):
            state = .pendingOrderCompleted(
                orderDetails: checkoutData.order
            )
        case (.bankAccount, false),
             (.bankTransfer, false),
             (.funds, false):
            state = .inactive
        case (.card, _):
            state = .authorizeCard(order: checkoutData.order)
        }
        
        let states = self.states(byAppending: state)
        apply(action: .next(to: state), states: states)
    }
}

extension StateService {
    public func cancelTransfer(with checkoutData: CheckoutData) {
        let states = self.states(byAppending: .transferCancellation(checkoutData))
        apply(action: .next(to: states.current), states: states)
    }
}

extension StateService {
    public func cardAuthorized(with paymentMethodId: String) {
        guard case .authorizeCard(order: let order) = statesRelay.value.current else {
            return
        }
        let states = self.states(
            byAppending: .pendingOrderCompleted(
                orderDetails: order
            )
        )
        apply(action: .next(to: states.current), states: states)
    }
}

extension StateService {
    public func orderCompleted() {
        let states = self.states(byAppending: .inactive)
        apply(action: .next(to: states.current), states: states)
    }
    
    public func orderPending(with orderDetails: OrderDetails) {
        let checkoutData = CheckoutData(order: orderDetails)
        let state = State.checkout(checkoutData)
        self.apply(
            action: .next(to: state),
            states: self.states(byAppending: state)
        )
    }
}

extension StateService.States: CustomDebugStringConvertible {
    var debugDescription: String {
        "current: \(current.debugDescription), previous: \(previous.map(\.debugDescription))"
    }
}

extension StateService.State: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        let suffix: String
        switch self {
        case .intro:
            suffix = "intro"
        case .selectFiat:
            suffix = "select-fiat"
        case .showURL:
            suffix = "show-url"
        case .unsupportedFiat:
            suffix = "unsupported-fiat"
        case .buy:
            suffix = "enter-amount-to-buy"
        case .changeFiat:
            suffix = "change-fiat"
        case .paymentMethods:
            suffix = "payment-methods"
        case .addCard:
            suffix = "add-card"
        case .kycBeforeCheckout:
            suffix = "kyc-before-checkout"
        case .kyc:
            suffix = "kyc"
        case .pendingKycApproval:
            suffix = "pending-kyc-approval"
        case .ineligible:
            suffix = "ineligible-for-buy"
        case .checkout:
            suffix = "checkout"
        case .bankTransferDetails:
            suffix = "bank-transfer-details"
        case .fundsTransferDetails:
            suffix = "funds-transfer-details"
        case .authorizeCard:
            suffix = "authorize-card"
        case .transferCancellation:
            suffix = "order-cancellation"
        case .pendingOrderDetails:
            suffix = "pending-order-details"
        case .pendingOrderCompleted:
            suffix = "pending-order-completed"
        case .linkBank:
            suffix = "link-bank"
        case .inactive:
            suffix = "inactive"
        }
        return "buy-state: \(suffix)"
    }
}
