// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class MviModel<State, Action: MviAction> where Action.State == State, State: Equatable {

    lazy var state: Observable<State> = stateRelay
        .distinctUntilChanged()
        .asObservable()
        .share(replay: 1, scope: .forever)

    let actions: ReplaySubject<Action> = ReplaySubject.create(bufferSize: 1)

    private var disposeBag = DisposeBag()
    private let stateRelay: BehaviorRelay<State>

    init(initialState: State, performAction: @escaping (State, Action) -> Disposable?) {
        stateRelay = BehaviorRelay(value: initialState)
        actions // TODO: Inject // actions.distinctUntilChanged()
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .scan(initialState) { oldState, action -> State in
                guard action.isValid(for: oldState) else {
                    return oldState
                }
                performAction(oldState, action)?
                    .disposed(by: self.disposeBag)
                return action.reduce(oldState: oldState)
            }
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }

    func process(action: Action) {
        actions.on(.next(action))
    }

    func destroy() {
        disposeBag = DisposeBag()
    }
}
