// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import FeatureKYCDomain
import Localization

private typealias L10n = LocalizationConstants.NewKYC

/// The `master` `State` for the Email Verification Flow
struct EmailVerificationState: Equatable {

    enum FlowStep {
        case loadingVerificationState
        case verifyEmailPrompt
        case emailVerificationHelp
        case editEmailAddress
        case emailVerifiedPrompt
        case verificationCheckFailed
    }

    var flowStep: FlowStep

    var verifyEmail: VerifyEmailState
    var emailVerificationHelp: EmailVerificationHelpState
    var editEmailAddress: EditEmailState
    var emailVerified: EmailVerifiedState

    var emailVerificationFailedAlert: AlertState<EmailVerificationAction>?

    init(emailAddress: String) {
        self.verifyEmail = VerifyEmailState(emailAddress: emailAddress)
        self.editEmailAddress = EditEmailState(emailAddress: emailAddress)
        self.emailVerificationHelp = EmailVerificationHelpState(emailAddress: emailAddress)
        self.emailVerified = EmailVerifiedState()
        self.flowStep = .verifyEmailPrompt
    }
}

/// The `master` `Action`type  for the Email Verification Flow
enum EmailVerificationAction: Equatable {
    case closeButtonTapped
    case didAppear
    case didDisappear
    case didEnterForeground
    case didReceiveEmailVerficationResponse(Result<EmailVerificationResponse, EmailVerificationCheckError>)
    case dismissEmailVerificationFailedAlert
    case loadVerificationState
    case presentStep(EmailVerificationState.FlowStep)
    case verifyEmail(VerifyEmailAction)
    case emailVerified(EmailVerifiedAction)
    case editEmailAddress(EditEmailAction)
    case emailVerificationHelp(EmailVerificationHelpAction)
}

/// The `master` `Environment` for the Email Verification Flow
struct EmailVerificationEnvironment {

    let analyticsRecorder: AnalyticsEventRecorderAPI
    let emailVerificationService: EmailVerificationServiceAPI
    let flowCompletionCallback: ((FlowResult) -> Void)?
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let pollingQueue: AnySchedulerOf<DispatchQueue>
    let openMailApp: () -> EffectTask<Bool>

    init(
        analyticsRecorder: AnalyticsEventRecorderAPI,
        emailVerificationService: EmailVerificationServiceAPI,
        flowCompletionCallback: ((FlowResult) -> Void)?,
        openMailApp: @escaping () -> EffectTask<Bool>,
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        pollingQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue.global(qos: .background).eraseToAnyScheduler()
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.emailVerificationService = emailVerificationService
        self.flowCompletionCallback = flowCompletionCallback
        self.mainQueue = mainQueue
        self.pollingQueue = pollingQueue
        self.openMailApp = openMailApp
    }
}

/// The `master` `Reducer` for the Email Verification Flow
let emailVerificationReducer = Reducer.combine(
    verifyEmailReducer.pullback(
        state: \EmailVerificationState.verifyEmail,
        action: /EmailVerificationAction.verifyEmail,
        environment: {
            VerifyEmailEnvironment(
                openMailApp: $0.openMailApp
            )
        }
    ),
    emailVerifiedReducer.pullback(
        state: \EmailVerificationState.emailVerified,
        action: /EmailVerificationAction.emailVerified,
        environment: { _ in
            EmailVerifiedEnvironment()
        }
    ),
    emailVerificationHelpReducer.pullback(
        state: \EmailVerificationState.emailVerificationHelp,
        action: /EmailVerificationAction.emailVerificationHelp,
        environment: {
            EmailVerificationHelpEnvironment(
                emailVerificationService: $0.emailVerificationService,
                mainQueue: $0.mainQueue
            )
        }
    ),
    editEmailReducer.pullback(
        state: \EmailVerificationState.editEmailAddress,
        action: /EmailVerificationAction.editEmailAddress,
        environment: {
            EditEmailEnvironment(
                emailVerificationService: $0.emailVerificationService,
                mainQueue: $0.mainQueue
            )
        }
    ),
    Reducer<EmailVerificationState, EmailVerificationAction, EmailVerificationEnvironment> { state, action, environment in
        struct TimerIdentifier: Hashable {}
        switch action {
        case .closeButtonTapped:
            environment.flowCompletionCallback?(.abandoned)
            environment.analyticsRecorder.record(
                event: AnalyticsEvents.New.Onboarding.emailVerificationSkipped(origin: .signUp)
            )
            return .none

        case .didAppear:
            return EffectTask.timer(
                id: TimerIdentifier(),
                every: 5,
                on: environment.pollingQueue
            )
            .map { _ in .loadVerificationState }
            .receive(on: environment.mainQueue)
            .eraseToEffect()

        case .didDisappear:
            return .cancel(id: TimerIdentifier())

        case .didEnterForeground:
            return .merge(
                EffectTask(value: .presentStep(.loadingVerificationState)),
                EffectTask(value: .loadVerificationState)
            )

        case .didReceiveEmailVerficationResponse(let response):
            switch response {
            case .success(let object):
                guard state.flowStep != .editEmailAddress else {
                    return .none
                }
                return EffectTask(
                    value: .presentStep(object.status == .verified ? .emailVerifiedPrompt : .verifyEmailPrompt)
                )

            case .failure(let error):
                state.emailVerificationFailedAlert = .init(
                    title: TextState(L10n.GenericError.title),
                    message: TextState(L10n.EmailVerification.couldNotLoadVerificationStatusAlertMessage),
                    primaryButton: .default(
                        TextState(L10n.GenericError.retryButtonTitle),
                        action: .send(.loadVerificationState)
                    ),
                    secondaryButton: .cancel(TextState(L10n.GenericError.cancelButtonTitle))
                )
                return EffectTask(value: .presentStep(.verificationCheckFailed))
            }

        case .loadVerificationState:
            return environment.emailVerificationService.checkEmailVerificationStatus()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(EmailVerificationAction.didReceiveEmailVerficationResponse)

        case .dismissEmailVerificationFailedAlert:
            state.emailVerificationFailedAlert = nil
            return .init(value: .presentStep(.verifyEmailPrompt))

        case .presentStep(let flowStep):
            state.flowStep = flowStep
            return .none

        case .verifyEmail(let subaction):
            switch subaction {
            case .tapGetEmailNotReceivedHelp:
                return .init(value: .presentStep(.emailVerificationHelp))

            default:
                return .none
            }

        case .emailVerified(let subaction):
            switch subaction {
            case .acknowledgeEmailVerification:
                environment.flowCompletionCallback?(.completed)
                return .none
            }

        case .emailVerificationHelp(let subaction):
            switch subaction {
            case .editEmailAddress:
                return .init(value: .presentStep(.editEmailAddress))

            case .didReceiveEmailSendingResponse(let response):
                switch response {
                case .success:
                    return .init(value: .presentStep(.verifyEmailPrompt))

                default:
                    break
                }
            case .sendVerificationEmail:
                environment.analyticsRecorder.record(event:
                    AnalyticsEvents.New.Onboarding.emailVerificationRequested(origin: .verification)
                )
            default:
                break
            }
            return .none

        case .editEmailAddress(let subaction):
            switch subaction {
            case .didReceiveSaveResponse(let response):
                switch response {
                case .success:
                    // updating email address for the flow so we are certain that (1.) the user wants to confirm and (2.) the change is reflected on the backend
                    state.verifyEmail.emailAddress = state.editEmailAddress.emailAddress
                    state.emailVerificationHelp.emailAddress = state.editEmailAddress.emailAddress
                    return .init(value: .presentStep(.verifyEmailPrompt))

                default:
                    break
                }
            case .save:
                environment.analyticsRecorder.record(event:
                    AnalyticsEvents.New.Onboarding.emailVerificationRequested(origin: .verification)
                )
            default:
                break
            }
            return .none
        }
    }
)
