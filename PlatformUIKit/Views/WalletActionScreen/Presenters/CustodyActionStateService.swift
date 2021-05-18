//
//  CustodySendStateService.swift
//  Blockchain
//
//  Created by AlexM on 2/6/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

public protocol RecoveryPhraseStatusProviding {
    var isRecoveryPhraseVerified: Bool { get }
    var isRecoveryPhraseVerifiedObservable: Observable<Bool> { get }
    var fetchTriggerRelay: PublishRelay<Void> { get }
}

public protocol CustodyActionStateReceiverServiceAPI: class {
        
    /// The action that should be executed, the `next` action
    /// is coupled with the current state
    var action: Observable<RoutingAction<CustodyActionState>> { get }
}

public protocol CustodySwapEmitterAPI: class {
    var swapRelay: PublishRelay<Void> { get }
}

public protocol CustodyActivityEmitterAPI: class {
    var activityRelay: PublishRelay<Void> { get }
}

public protocol CustodyDepositEmitterAPI: class {
    var depositRelay: PublishRelay<Void> { get }
}

public protocol CustodyWithdrawEmitterAPI: class {
    var withdrawRelay: PublishRelay<Void> { get }
}

public protocol CustodyBuyEmitterAPI: class {
    var buyRelay: PublishRelay<Void> { get }
}

public protocol CustodySellEmitterAPI: class {
    var sellRelay: PublishRelay<Void> { get }
}

public typealias CustodyActionStateServiceAPI = CustodyActionStateReceiverServiceAPI &
                                         RoutingNextStateEmitterAPI &
                                         CustodyActivityEmitterAPI &
                                         CustodyBuyEmitterAPI &
                                         CustodySellEmitterAPI &
                                         CustodyDepositEmitterAPI &
                                         RoutingPreviousStateEmitterAPI &
                                         CustodyWithdrawEmitterAPI &
                                         CustodySwapEmitterAPI

public final class CustodyActionStateService: CustodyActionStateServiceAPI {
    public typealias State = CustodyActionState
    public typealias Action = RoutingAction<State>

    // MARK: - Types
            
    public struct States {
        
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
    
    public var states: Observable<States> {
        statesRelay.asObservable()
    }
    
    public var currentState: Observable<CustodyActionStateService.State> {
        states.map { $0.current }
    }
    
    public var action: Observable<Action> {
        actionRelay
            .observeOn(MainScheduler.instance)
    }
    
    public let nextRelay = PublishRelay<Void>()
    public let previousRelay = PublishRelay<Void>()
    public let activityRelay = PublishRelay<Void>()
    public let depositRelay = PublishRelay<Void>()
    public let sellRelay = PublishRelay<Void>()
    public let buyRelay = PublishRelay<Void>()
    public let withdrawRelay = PublishRelay<Void>()
    public let swapRelay = PublishRelay<Void>()
    
    private let statesRelay = BehaviorRelay<States>(value: .start)
    private let actionRelay = PublishRelay<Action>()
    private let cacheSuite: CacheSuite
    private let recoveryStatusProviding: RecoveryPhraseStatusProviding
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    public init(cacheSuite: CacheSuite = resolve(),
                kycTiersService: KYCTiersServiceAPI = resolve(),
                recoveryStatusProviding: RecoveryPhraseStatusProviding) {
        self.recoveryStatusProviding = recoveryStatusProviding
        self.cacheSuite = cacheSuite
        
        nextRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in self.next() }
            .disposed(by: disposeBag)
        
        previousRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in self.previous() }
            .disposed(by: disposeBag)

        activityRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                let nextStates = self.statesRelay.value.states(byAppending: .activity)
                self.apply(action: .next(.activity), states: nextStates)
            }
            .disposed(by: disposeBag)
        
        swapRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                let nextStates = self.statesRelay.value.states(byAppending: .swap)
                self.apply(action: .next(.swap), states: nextStates)
            }
            .disposed(by: disposeBag)
        
        depositRelay
            .observeOn(MainScheduler.instance)
            .flatMap {
                kycTiersService
                .fetchTiers()
                .asObservable()
            }
            .map { $0.isTier2Approved }
            .catchErrorJustReturn(false)
            .bindAndCatch(weak: self) { (self, isKYCApproved) in
                let nextStates = self.statesRelay.value.states(byAppending: .deposit(isKYCApproved: isKYCApproved))
                self.apply(action: .next(.deposit(isKYCApproved: isKYCApproved)), states: nextStates)
            }
            .disposed(by: disposeBag)
        
        buyRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                let nextStates = self.statesRelay.value.states(byAppending: .buy)
                self.apply(action: .next(.buy), states: nextStates)
            }
            .disposed(by: disposeBag)
        
        sellRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                let nextStates = self.statesRelay.value.states(byAppending: .sell)
                self.apply(action: .next(.sell), states: nextStates)
            }
            .disposed(by: disposeBag)

        withdrawRelay
            .observeOn(MainScheduler.instance)
            .flatMap {
                kycTiersService
                    .fetchTiers()
                    .asObservable()
            }
            .map { $0.isTier2Approved }
            .catchErrorJustReturn(false)
            .bindAndCatch(weak: self) { (self, isKYCApproved) in
                let nextStates = self.statesRelay.value.states(byAppending: .withdrawalFiat(isKYCApproved: isKYCApproved))
                self.apply(action: .next(.withdrawalFiat(isKYCApproved: isKYCApproved)), states: nextStates)
            }
            .disposed(by: disposeBag)
    }
    
    private func next() {
        let action: Action
        var state: State
        let states = statesRelay.value
        switch states.current {
        case .start:
            state = .send
            action = .next(state)
        case .introduction:
            cacheSuite.set(true, forKey: Constant.introScreenShown)
            state = recoveryStatusProviding.isRecoveryPhraseVerified ? .withdrawal : .backupAfterIntroduction
            action = .next(state)
        case .backupAfterIntroduction, .backup:
            state = recoveryStatusProviding.isRecoveryPhraseVerified ? .withdrawalAfterBackup : .end
            action = .next(state)
        case .send:
            state = hasShownCustodyIntroductionScreen ? .backup : .introduction
            state = recoveryStatusProviding.isRecoveryPhraseVerified ? .withdrawal : state
            action = .next(state)
        case .activity,
             .buy,
             .sell,
             .withdrawal,
             .deposit,
             .withdrawalFiat,
             .withdrawalAfterBackup,
             .swap,
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
