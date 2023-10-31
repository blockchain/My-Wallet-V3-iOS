import Blockchain
import ErrorsUI

public struct OnboardingFlow: Decodable, Hashable {
    public var next_action: NextAction; public struct NextAction: Decodable, Hashable {
        public let slug: Slug
        public let metadata: AnyJSON
    }
}

extension OnboardingFlow {

    public struct Slug: NewTypeString {
        public var value: String
        public init(_ value: String) { self.value = value }
    }
}

extension OnboardingFlow.Slug {
    public static let prove: Self = "PROVE"
    public static let proveChallenge: Self = "PROVE_CHALLENGE"
    public static let provePhoneNumberVerification: Self = "PROVE_PHONE_NUMBER_VERIFICATION"
    public static let verificationInProgress: Self = "VERIFICATION_IN_PROGRESS"
    public static let loading: Self = "LOADING"
    public static let veriff: Self = "VERIFF"
    public static let questions: Self = "KYC_QUESTIONS"
    public static let veriffIntroduction: Self = "VERIFF_INTRODUCTION"
    public static let error: Self = "ERROR"
    public static let none: Self = "NONE"
    public static let pendingKYC: Self = "PENDING_KYC"
}

extension OnboardingFlow.Slug: CaseIterable {
    public static var allCases: [OnboardingFlow.Slug] = [.prove, .veriff, .error]
}

extension OnboardingFlow: WhichFlowSequenceViewController {

    private static let lock: UnfairLock = UnfairLock()
    private var lock: UnfairLock { Self.lock }

    public private(set) static var map: [OnboardingFlow.Slug: (AnyJSON) throws -> FlowSequenceViewController] = [
        .error: makeErrorFlowSequenceViewController,
        .proveChallenge: makeChallengeFlowSequenceViewController(_:),
        .provePhoneNumberVerification: makePhoneNumberVerificationFlowSequenceViewController,
        .verificationInProgress: makeVerificationInProgressFlowSequenceViewController,
        .loading: makeInProgressFlowSequenceViewController,
        .veriffIntroduction: makeVeriffIntroductionFlowSequenceViewController,
        .pendingKYC: makeApplicationSubmittedViewFlowSequenceViewController
    ]

    public static func register(_ slug: OnboardingFlow.Slug, _ builder: @escaping (AnyJSON) throws -> FlowSequenceViewController) {
        lock.withLock { map[slug] = builder }
    }

    public func viewController() -> FlowSequenceViewController {
        do {
            if let viewController = lock.withLock(body: { Self.map[next_action.slug] }) {
                return try viewController(next_action.metadata)
            } else {
                throw "\(next_action.slug.value) has no associated view.".error()
            }
        } catch {
            return FlowSequenceHostingViewController { completion in
                ErrorView(ux: UX.Error(error: error), navigationBarClose: false, dismiss: completion)
            }
        }
    }
}

/* Defaults */

func makeInProgressFlowSequenceViewController(_ metadata: AnyJSON) throws -> FlowSequenceViewController {
    FlowSequenceHostingViewController { completion in
        InProgressView()
            .task {
                do {
                    try await Task.sleep(nanoseconds: 3 * NSEC_PER_SEC)
                    completion()
                } catch {
                    print("‼️", error)
                }
            }
    }
}

func makeVerificationInProgressFlowSequenceViewController(_ metadata: AnyJSON) throws -> FlowSequenceViewController {
    FlowSequenceHostingViewController { _ in
        VerificationInProgressView()
    }
}

func makeApplicationSubmittedViewFlowSequenceViewController(_ metadata: AnyJSON) throws -> FlowSequenceViewController {
    FlowSequenceHostingViewController { completion in
        ApplicationSubmittedView(completion: completion)
    }
}


func makeVeriffIntroductionFlowSequenceViewController(_ metadata: AnyJSON) throws -> FlowSequenceViewController {
    FlowSequenceHostingViewController { completion in
        VeriffManualInputIntroductionView(completion: completion)
    }
}

func makeChallengeFlowSequenceViewController(_ metadata: AnyJSON) throws -> FlowSequenceViewController {
    let challenge: ChallengeType = try metadata["challenge_type"].decode(ChallengeType.self)
    return FlowSequenceHostingViewController { completion in
        ChallengeView(
            challenge: challenge,
            toLegacyKYC: {},
            completion: completion
        )
    }
}

func makePhoneNumberVerificationFlowSequenceViewController(_ metadata: AnyJSON) throws -> FlowSequenceViewController {
    FlowSequenceHostingViewController { completion in
        PhoneNumberVerificationView(completion: completion)
    }
}

func makePersonalInformationConfirmationFlowSequenceViewController(_ metadata: AnyJSON) throws -> FlowSequenceViewController {
    let id: String = try metadata["prefillId"].decode(String.self)
    @Dependency(\.KYCOnboardingService) var KYCOnboardingService
    return FlowSequenceHostingViewController { completion in
        AsyncContentView(
            source: { try await KYCOnboardingService.lookupPrefill(id: id) },
            errorView: { error in ErrorView(ux: UX.Error(error: error)) },
            content: { personalInformation in
                PersonalInformationConfirmationView(personalInformation: personalInformation, completion: completion)
            }
        )
    }
}

func makeErrorFlowSequenceViewController(_ metadata: AnyJSON) throws -> FlowSequenceViewController {
    try FlowSequenceHostingViewController { completion in
        do {
            return try ErrorView(ux: UX.Error(nabu: metadata.decode(Nabu.Error.self)), navigationBarClose: false, dismiss: completion)
        } catch {
            return try ErrorView(ux: UX.Error(error: metadata.as(Error.self)), navigationBarClose: false, dismiss: completion)
        }
    }
}
