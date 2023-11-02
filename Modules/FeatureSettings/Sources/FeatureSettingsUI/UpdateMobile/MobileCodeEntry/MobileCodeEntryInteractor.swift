// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift
import ToolKit

final class MobileCodeEntryInteractor {

    // MARK: - Public

    enum InteractionState {

        enum ErrorType {
            /// An error occured resending the code
            case resending

            /// An error occured verifying the code
            case verifying
        }

        /// Code entry is ready
        case ready

        /// The code is being resent
        case resending

        /// The user is submitting a code entry
        case submitting

        /// The code was successfully submitted and verified
        case verified

        /// There was an error verifying or resending the code
        case error(ErrorType)

        /// An unknown state
        case unknown

        var isComplete: Bool {
            switch self {
            case .verified:
                true
            default:
                false
            }
        }

        var isReady: Bool {
            switch self {
            case .ready,
                 .verified,
                 .error,
                 .unknown:
                true
            default:
                false
            }
        }

        var isLoading: Bool {
            switch self {
            case .resending,
                 .submitting:
                true
            default:
                false
            }
        }
    }

    enum Action {
        /// Resend the 4-Digit code
        case resend

        /// Verify the 4-Digit code
        case verify
    }

    var actionRelay = PublishRelay<Action>()
    var contentRelay = BehaviorRelay<String>(value: "")
    var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }

    // MARK: - Private Accessors

    private let verificationInteractor: VerifyCodeEntryInteractor
    private let updateMobileInteractor: UpdateMobileScreenInteractor
    private let stateRelay = BehaviorRelay<InteractionState>(value: .ready)
    private let disposeBag = DisposeBag()

    init(service: MobileSettingsServiceAPI) {
        self.verificationInteractor = VerifyCodeEntryInteractor(service: service)
        self.updateMobileInteractor = UpdateMobileScreenInteractor(service: service)

        Observable.combineLatest(
            verificationInteractor.interactionState,
            updateMobileInteractor.interactionState
        )
        .map { payload -> InteractionState in
            let verification = payload.0
            let update = payload.1
            switch (verification, update) {
            case (.complete, .complete),
                 (.complete, .ready):
                return .verified
            case (.ready, .ready):
                return .ready
            case (.verifying, .ready):
                return .submitting
            case (.failed, .ready):
                return .error(.verifying)
            case (.ready, .updating):
                return .resending
            case (.ready, .complete):
                return .ready
            case (.ready, .failed):
                return .error(.resending)
            default:
                return .unknown
            }
        }
        .bindAndCatch(to: stateRelay)
        .disposed(by: disposeBag)

        actionRelay
            .bindAndCatch(weak: self) { (self, action) in
                switch action {
                case .resend:
                    self.resend()
                case .verify:
                    self.verify()
                }
            }
            .disposed(by: disposeBag)

        contentRelay
            .bindAndCatch(to: verificationInteractor.contentRelay)
            .disposed(by: disposeBag)

        service.valueObservable
            .compactMap(\.smsNumber)
            .bindAndCatch(to: updateMobileInteractor.contentRelay)
            .disposed(by: disposeBag)
    }

    private func resend() {
        updateMobileInteractor.triggerRelay.accept(())
    }

    private func verify() {
        verificationInteractor.triggerRelay.accept(())
    }
}
