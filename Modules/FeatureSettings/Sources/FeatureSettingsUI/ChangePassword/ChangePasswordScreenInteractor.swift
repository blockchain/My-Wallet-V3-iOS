// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import FeatureAuthenticationDomain
import PlatformKit
import RxRelay
import RxSwift

final class ChangePasswordScreenInteractor {

    enum State {
        case unknown
        case ready
        case updating
        case passwordUnknown
        case incorrectPassword
        case complete
        case failed

        var isLoading: Bool {
            switch self {
            case .updating:
                return true
            default:
                return false
            }
        }

        var isComplete: Bool {
            switch self {
            case .complete:
                return true
            default:
                return false
            }
        }
    }

    struct InteractorInput {
        let currentPassword: String
        let newPassword: String
    }

    let triggerRelay = PublishRelay<Void>()
    let contentRelay: BehaviorRelay<InteractorInput> = BehaviorRelay(value: .empty)
    var state: Observable<State> {
        stateRelay.asObservable()
    }

    // MARK: - Injected

    private let stateRelay = BehaviorRelay<State>(value: .unknown)
    private let currentPasswordRelay = BehaviorRelay<String>(value: "")
    private let passwordRepository: PasswordRepositoryAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let disposeBag = DisposeBag()

    // MARK: - Init

    init(
        passwordAPI: PasswordRepositoryAPI,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.passwordRepository = passwordAPI
        self.analyticsRecorder = analyticsRecorder

        passwordRepository.hasPassword.asSingle()
            .observe(on: MainScheduler.instance)
            .map { hasPassword -> State in
                hasPassword ? .passwordUnknown : .ready
            }
            .subscribe(onSuccess: { [weak self] state in
                guard let self else { return }
                stateRelay.accept(state)
            })
            .disposed(by: disposeBag)

        passwordRepository.password.asObservable()
            .compactMap { $0 }
            .bindAndCatch(to: currentPasswordRelay)
            .disposed(by: disposeBag)

        triggerRelay
            .bindAndCatch(weak: self) { (self) in
                self.changePassword()
            }
            .disposed(by: disposeBag)
    }

    private func changePassword() {
        let current = currentPasswordRelay.value
        let input = contentRelay.value
        guard current == input.currentPassword else {
            stateRelay.accept(.incorrectPassword)
            return
        }

        update(state: .updating)
            .andThen(passwordRepository.changePassword(password: input.newPassword).asCompletable())
            .subscribe(on: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onCompleted: { [weak self] in
                    self?.stateRelay.accept(.complete)
                    self?.analyticsRecorder.record(event: AnalyticsEvents.New.Security.accountPasswordChanged)
                },
                onError: { [weak self] _ in
                    self?.stateRelay.accept(.failed)
                }
            )
            .disposed(by: disposeBag)
    }

    private func update(state: State) -> Completable {
        Completable.create { [weak self] observer -> Disposable in
            self?.stateRelay.accept(state)
            observer(.completed)
            return Disposables.create()
        }
    }
}

extension ChangePasswordScreenInteractor.InteractorInput {
    static let empty: ChangePasswordScreenInteractor.InteractorInput = .init(currentPassword: "", newPassword: "")
}
