// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureCardPaymentDomain
import RIBs
import RxCocoa
import RxRelay
import RxSwift
import RxToolKit

public protocol CardAuthorizationRoutingInteractorAPI: AnyObject {
    func cardAuthorized(with paymentMethodId: String)
}

public final class CardRouterInteractor: Interactor {

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
    enum State {

        /// Card details screen
        case cardDetails

        /// Billing address screen
        case billingAddress(CardData)

        /// Authorization screen (in-app web view)
        case authorization(PartnerAuthorizationData)

        /// Pending card state
        case pendingCardState(cardId: String)

        /// Completed state
        case completed(CardData)

        /// Inactive state
        case inactive
    }

    enum Action {
        case next(to: State)
        case previous(from: State)
    }

    // MARK: - Properties

    /// Fire onces upon completion of the entire process
    public var completionCardData: Observable<CardData> {
        action
            .compactMap { action in
                switch action {
                case .next(to: .completed(let data)):
                    return data
                default:
                    return nil
                }
            }
            .take(1)
    }

    public var pending: Observable<String> {
        action
            .compactMap { action in
                switch action {
                case .next(to: .pendingCardState(let cardId)):
                    return cardId
                default:
                    return nil
                }
            }
            .take(1)
    }

    public var cancellation: Observable<Void> {
        cancellationRelay
            .take(1)
    }

    var action: Observable<Action> {
        actionRelay
            .observe(on: MainScheduler.instance)
    }

    private let cancellationRelay = PublishRelay<Void>()

    private let statesRelay = BehaviorRelay<States>(value: .inactive)
    let previousRelay = PublishRelay<Void>()

    private let actionRelay = PublishRelay<Action>()
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override public func didBecomeActive() {
        super.didBecomeActive()

        previousRelay
            .observe(on: MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in self.previous() }
            .disposed(by: disposeBag)

        let states = States(current: .cardDetails, previous: [.inactive])
        apply(action: .next(to: states.current), states: states)
    }

    // MARK: - Basic Navigation

    public func end(with data: CardData) {
        let states = statesRelay.value.states(byAppending: .completed(data))
        apply(action: .next(to: states.current), states: states)
    }

    public func dismiss() {
        let states = statesRelay.value.states(byAppending: .inactive)
        apply(action: .next(to: states.current), states: states)
    }

    // MARK: - Other Customized Navigation

    public func addBillingAddress(to cardData: CardData) {
        let states = statesRelay.value.states(byAppending: .billingAddress(cardData))
        apply(action: .next(to: states.current), states: states)
    }

    public func authorizeCardAddition(with data: PartnerAuthorizationData) {
        let states = statesRelay.value.states(byAppending: .authorization(data))
        apply(action: .next(to: states.current), states: states)
    }

    // MARK: - Accessors

    private func previous() {
        let last = statesRelay.value.current
        let states = statesRelay.value.statesByRemovingLast()
        apply(action: .previous(from: last), states: states)

        switch states.current {
        case .inactive:
            cancellationRelay.accept(())
        default:
            break
        }
    }

    private func apply(action: Action, states: States) {
        actionRelay.accept(action)
        statesRelay.accept(states)
    }
}

extension CardRouterInteractor: CardAuthorizationRoutingInteractorAPI {
    public func cardAuthorized(with identifier: String) {
        let states = statesRelay.value.states(byAppending: .pendingCardState(cardId: identifier))
        apply(action: .next(to: states.current), states: states)
    }
}
