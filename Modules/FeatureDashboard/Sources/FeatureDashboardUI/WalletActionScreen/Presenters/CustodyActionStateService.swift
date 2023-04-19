// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

protocol CustodyActionStateReceiverServiceAPI: AnyObject {

    /// The action that should be executed, the `next` action
    /// is coupled with the current state
    var action: Observable<RoutingAction<CustodyActionState>> { get }
}

protocol CustodySwapEmitterAPI: AnyObject {
    var swapRelay: PublishRelay<Void> { get }
}

protocol CustodyActivityEmitterAPI: AnyObject {
    var activityRelay: PublishRelay<Void> { get }
}

protocol CustodyDepositEmitterAPI: AnyObject {
    var depositRelay: PublishRelay<Void> { get }
}

protocol CustodyWithdrawEmitterAPI: AnyObject {
    var withdrawRelay: PublishRelay<Void> { get }
}

protocol CustodyBuyEmitterAPI: AnyObject {
    var buyRelay: PublishRelay<Void> { get }
}

protocol CustodySendEmitterAPI: AnyObject {
    var sendRelay: PublishRelay<Void> { get }
}

protocol CustodyReceiveEmitterAPI: AnyObject {
    var receiveRelay: PublishRelay<Void> { get }
}

protocol CustodySellEmitterAPI: AnyObject {
    var sellRelay: PublishRelay<Void> { get }
}

typealias CustodyActionStateServiceAPI = CustodyActionStateReceiverServiceAPI &
    RoutingNextStateEmitterAPI &
    CustodyActivityEmitterAPI &
    CustodyBuyEmitterAPI &
    CustodySellEmitterAPI &
    CustodyDepositEmitterAPI &
    RoutingPreviousStateEmitterAPI &
    CustodyWithdrawEmitterAPI &
    CustodySwapEmitterAPI &
    CustodySendEmitterAPI &
    CustodyReceiveEmitterAPI

final class CustodyActionStateService: CustodyActionStateServiceAPI {
    typealias State = CustodyActionState
    typealias Action = RoutingAction<State>

    // MARK: - Types

    struct States {

        /// The actual state of the flow
        let current: State

        /// The previous states sorted chronologically
        let previous: [State]

        /// The starting state
        static var start: States {
            States(current: .start, previous: [])
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
        /// state is trimmed off.
        func statesByRemovingLast() -> States {
            States(
                current: previous.last ?? .end,
                previous: previous.dropLast()
            )
        }
    }

    // MARK: - Types

    private enum Constant {
        static let introScreenShown = "custodySendInterstitialViewed"
    }

    // MARK: - Properties

    var hasShownCustodyIntroductionScreen: Bool {
        cacheSuite.bool(forKey: Constant.introScreenShown)
    }

    var states: Observable<States> {
        statesRelay.asObservable()
    }

    var currentState: Observable<State> {
        states.map(\.current)
    }

    var action: Observable<Action> {
        actionRelay
            .observe(on: MainScheduler.instance)
    }

    let nextRelay = PublishRelay<Void>()
    let previousRelay = PublishRelay<Void>()
    let activityRelay = PublishRelay<Void>()
    let depositRelay = PublishRelay<Void>()
    let sellRelay = PublishRelay<Void>()
    let buyRelay = PublishRelay<Void>()
    let withdrawRelay = PublishRelay<Void>()
    let swapRelay = PublishRelay<Void>()
    let sendRelay = PublishRelay<Void>()
    let receiveRelay = PublishRelay<Void>()

    private let statesRelay = BehaviorRelay<States>(value: .start)
    private let actionRelay = PublishRelay<Action>()
    private let cacheSuite: CacheSuite
    private let recoveryStatusProviding: RecoveryPhraseStatusProviding

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        cacheSuite: CacheSuite = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        recoveryStatusProviding: RecoveryPhraseStatusProviding
    ) {
        self.recoveryStatusProviding = recoveryStatusProviding
        self.cacheSuite = cacheSuite

        nextRelay
            .observe(on: MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in self.next() }
            .disposed(by: disposeBag)

        previousRelay
            .observe(on: MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in self.previous() }
            .disposed(by: disposeBag)

        activityRelay
            .observe(on: MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                let nextStates = self.statesRelay.value.states(byAppending: .activity)
                self.apply(action: .next(.activity), states: nextStates)
            }
            .disposed(by: disposeBag)

        swapRelay
            .observe(on: MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                let nextStates = self.statesRelay.value.states(byAppending: .swap)
                self.apply(action: .next(.swap), states: nextStates)
            }
            .disposed(by: disposeBag)

        depositRelay
            .observe(on: MainScheduler.instance)
            .flatMap {
                kycTiersService
                    .fetchTiers()
                    .asObservable()
            }
            .map(\.isVerifiedApproved)
            .catchAndReturn(false)
            .bindAndCatch(weak: self) { (self, isKYCApproved) in
                let nextStates = self.statesRelay.value.states(byAppending: .deposit(isKYCApproved: isKYCApproved))
                self.apply(action: .next(.deposit(isKYCApproved: isKYCApproved)), states: nextStates)
            }
            .disposed(by: disposeBag)

        buyRelay
            .observe(on: MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                let nextStates = self.statesRelay.value.states(byAppending: .buy)
                self.apply(action: .next(.buy), states: nextStates)
            }
            .disposed(by: disposeBag)

        sellRelay
            .observe(on: MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                let nextStates = self.statesRelay.value.states(byAppending: .sell)
                self.apply(action: .next(.sell), states: nextStates)
            }
            .disposed(by: disposeBag)

        sendRelay
            .observe(on: MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                let nextStates = self.statesRelay.value.states(byAppending: .send)
                self.apply(action: .next(.send), states: nextStates)
            }
            .disposed(by: disposeBag)

        receiveRelay
            .observe(on: MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                let nextStates = self.statesRelay.value.states(byAppending: .receive)
                self.apply(action: .next(.receive), states: nextStates)
            }
            .disposed(by: disposeBag)

        withdrawRelay
            .observe(on: MainScheduler.instance)
            .flatMap {
                kycTiersService
                    .fetchTiers()
                    .asObservable()
            }
            .map(\.isVerifiedApproved)
            .catchAndReturn(false)
            .bindAndCatch(weak: self) { (self, isKYCApproved) in
                let nextStates = self.statesRelay.value.states(byAppending: .withdrawalFiat(isKYCApproved: isKYCApproved))
                self.apply(action: .next(.withdrawalFiat(isKYCApproved: isKYCApproved)), states: nextStates)
            }
            .disposed(by: disposeBag)
    }

    private var isRecoveryPhraseVerified: Bool {
        recoveryStatusProviding.isRecoveryPhraseVerifiedAtomic.value
    }

    private func next() {
        let action: Action
        var state: State
        let states = statesRelay.value
        switch states.current {
        case .start:
            state = .start
            action = .next(state)
        case .introduction:
            cacheSuite.set(true, forKey: Constant.introScreenShown)
            state = isRecoveryPhraseVerified ? .withdrawal : .backupAfterIntroduction
            action = .next(state)
        case .backupAfterIntroduction, .backup:
            state = isRecoveryPhraseVerified ? .withdrawalAfterBackup : .end
            action = .next(state)
        case .send:
            switch (isRecoveryPhraseVerified, hasShownCustodyIntroductionScreen) {
            case (false, false):
                state = .introduction
            case (false, true):
                state = .backup
            case (true, _):
                state = .withdrawal
            }
            action = .next(state)
        case .activity,
             .buy,
             .sell,
             .withdrawal,
             .deposit,
             .withdrawalFiat,
             .withdrawalAfterBackup,
             .swap,
             .receive,
             .end:
            state = .end
            action = .next(state)
        }
        let nextStates = states.states(byAppending: state)
        apply(action: action, states: nextStates)
    }

    private func previous() {
        let states = statesRelay.value.statesByRemovingLast()
        let action: Action
        switch states.current {
        case .end, .start, .introduction, .backupAfterIntroduction, .send:
            action = .dismiss
        default:
            action = .previous
        }
        apply(action: action, states: states)
    }

    private func apply(action: Action, states: States) {
        actionRelay.accept(action)
        statesRelay.accept(states)
    }
}
