// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Blockchain
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

    @PresentationState var emailVerificationFailedAlert: AlertState<EmailVerificationAction.AlertAction>?

    init(emailAddress: String) {
        self.verifyEmail = VerifyEmailState(emailAddress: emailAddress)
        self.editEmailAddress = EditEmailState(emailAddress: emailAddress)
        self.emailVerificationHelp = EmailVerificationHelpState(emailAddress: emailAddress)
        self.emailVerified = EmailVerifiedState(emailAddress: emailAddress)
        self.flowStep = .verifyEmailPrompt
    }
}

/// The `master` `Action`type  for the Email Verification Flow
enum EmailVerificationAction: Equatable {
    enum AlertAction {
        case dismiss
        case loadVerificationState
    }
    case closeButtonTapped
    case didAppear
    case didDisappear
    case didEnterForeground
    case didReceiveEmailVerficationResponse(Result<EmailVerificationResponse, EmailVerificationCheckError>)
    case loadVerificationState
    case presentStep(EmailVerificationState.FlowStep)
    case verifyEmail(VerifyEmailAction)
    case emailVerified(EmailVerifiedAction)
    case editEmailAddress(EditEmailAction)
    case emailVerificationHelp(EmailVerificationHelpAction)
    case alert(PresentationAction<AlertAction>)
}

struct EmailVerificationReducer: Reducer {

    typealias State = EmailVerificationState
    typealias Action = EmailVerificationAction

    let analyticsRecorder: AnalyticsEventRecorderAPI
    let emailVerificationService: EmailVerificationServiceAPI
    let flowCompletionCallback: ((FlowResult) -> Void)?
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let pollingQueue: AnySchedulerOf<DispatchQueue>
    let openMailApp: () async -> Bool
    let app: AppProtocol

    init(
        analyticsRecorder: AnalyticsEventRecorderAPI,
        emailVerificationService: EmailVerificationServiceAPI,
        flowCompletionCallback: ((FlowResult) -> Void)?,
        openMailApp: @escaping () async -> Bool,
        app: AppProtocol,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        pollingQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.emailVerificationService = emailVerificationService
        self.flowCompletionCallback = flowCompletionCallback
        self.mainQueue = mainQueue
        self.app = app
        self.pollingQueue = pollingQueue
        self.openMailApp = openMailApp
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.verifyEmail, action: /Action.verifyEmail) {
            VerifyEmailReducer(openMailApp: openMailApp)
        }
        Scope(state: \EmailVerificationState.emailVerified, action: /Action.emailVerified) {
            EmailVerifiedReducer()
        }
        Scope(state: \.emailVerificationHelp, action: /Action.emailVerificationHelp) {
            EmailVerificationHelpReducer(
                emailVerificationService: emailVerificationService,
                mainQueue: mainQueue
            )
        }
        Scope(state: \.editEmailAddress, action: /Action.editEmailAddress) {
            EditEmailReducer(
                emailVerificationService: emailVerificationService,
                mainQueue: mainQueue
            )
        }
        Reduce { state, action in
            struct TimerIdentifier: Hashable {}
            switch action {
            case .closeButtonTapped:
                flowCompletionCallback?(.abandoned)
                analyticsRecorder.record(
                    event: AnalyticsEvents.New.Onboarding.emailVerificationSkipped(origin: .signUp)
                )
                return .none

            case .didAppear:
                return Effect.run { send in
                    for await _ in pollingQueue.timer(interval: .seconds(5)) {
                        mainQueue.schedule {
                            do {
                                Task { @MainActor in
                                    send(.loadVerificationState)
                                }
                            }
                        }
                    }
                }
                .cancellable(id: TimerIdentifier())

            case .didDisappear:
                return .cancel(id: TimerIdentifier())

            case .didEnterForeground:
                return .merge(
                    Effect.send(.presentStep(.loadingVerificationState)),
                    Effect.send(.loadVerificationState)
                )

            case .didReceiveEmailVerficationResponse(let response):
                switch response {
                case .success(let object):
                    guard state.flowStep != .editEmailAddress else {
                        return .none
                    }
                    return Effect.send(
                        .presentStep(object.status == .verified ? .emailVerifiedPrompt : .verifyEmailPrompt)
                    )

                case .failure:
                    state.emailVerificationFailedAlert = .init(
                        title: TextState(L10n.GenericError.title),
                        message: TextState(L10n.EmailVerification.couldNotLoadVerificationStatusAlertMessage),
                        primaryButton: .default(
                            TextState(L10n.GenericError.retryButtonTitle),
                            action: .send(.loadVerificationState)
                        ),
                        secondaryButton: .cancel(TextState(L10n.GenericError.cancelButtonTitle))
                    )
                    return Effect.send(.presentStep(.verificationCheckFailed))
                }

            case .loadVerificationState, .alert(.presented(.loadVerificationState)):
                return .run { send in
                    do {
                        let status = try await emailVerificationService
                            .checkEmailVerificationStatus()
                            .receive(on: mainQueue).await()
                        await send(.didReceiveEmailVerficationResponse(.success(status)))
                    } catch {
                        await send(.didReceiveEmailVerficationResponse(.failure(error as! EmailVerificationCheckError)))
                    }
                }

            case .alert(.presented(.dismiss)), .alert(.dismiss):
                state.emailVerificationFailedAlert = nil
                return Effect.send(.presentStep(.verifyEmailPrompt))

            case .presentStep(let flowStep):
                state.flowStep = flowStep
                return .none

            case .verifyEmail(let subaction):
                switch subaction {
                case .tapGetEmailNotReceivedHelp:
                    return Effect.send(.presentStep(.emailVerificationHelp))

                default:
                    return .none
                }

            case .emailVerified(let subaction):
                switch subaction {
                case .acknowledgeEmailVerification:
                    flowCompletionCallback?(.completed)
                    return .run { _ in
                        app.post(event: blockchain.ux.kyc.event.status.did.change)
                    }
                }

            case .emailVerificationHelp(let subaction):
                switch subaction {
                case .editEmailAddress:
                    return Effect.send(.presentStep(.editEmailAddress))

                case .didReceiveEmailSendingResponse(let response):
                    switch response {
                    case .success:
                        return Effect.send(.presentStep(.verifyEmailPrompt))

                    default:
                        break
                    }
                case .alert(.presented(.sendVerificationEmail)):
                    analyticsRecorder.record(event:
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
                        return Effect.send(.presentStep(.verifyEmailPrompt))

                    default:
                        break
                    }
                case .save:
                    analyticsRecorder.record(event:
                        AnalyticsEvents.New.Onboarding.emailVerificationRequested(origin: .verification)
                    )
                default:
                    break
                }
                return .none
            }
        }
    }
}
