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
    public static let proveMobileAuth: Self = "PROVE_MOBILE_AUTH" // Determines if mobile auth is possible
    public static let proveCollectData: Self = "PROVE_INSTANT_LINK_COLLECT_DATA" // Collects phone number and challenge
    public static let proveChallenge: Self = "PROVE_CHALLENGE" // Collects challenge only
    public static let proveSmsLoading: Self = "PROVE_INSTANT_LINK_SMS_LOADING" // SMS sent screen
    public static let proveApplicationSubmitted: Self = "PROVE_APPLICATION_SUBMITTED" // Application submitted
    public static let provePrefillData: Self = "PROVE_PREFILL_DATA" // Personal info
    public static let displayMessage: Self = "DISPLAY_MESSAGE" // Error message screen?
    public static let pendingKYC: Self = "PENDING_KYC" // Loading screen

    public static let collectKyc: Self = "COLLECT_KYC" // Veriff flow
    public static let collectSsn: Self = "COLLECT_SSN" // Legacy SSN collection
    public static let collectUserData: Self = "COLLECT_USERDATA_FULL" // Legacy KYC

    // KYC Questions: has the context enum as a metadata field: `"TIER_TWO_VERIFICATION", "FIAT_DEPOSIT", "FIAT_WITHDRAW", "TRADING","PROVE_ONBOARDING_FLOW"`
    public static let collectKycQuestions: Self = "COLLECT_KYC_QUESTIONS"
}

extension OnboardingFlow.Slug: CaseIterable {
    public static var allCases: [OnboardingFlow.Slug] = [
        .proveMobileAuth,
        .displayMessage,
        .proveChallenge,
        .proveCollectData,
        .proveSmsLoading,
        .proveApplicationSubmitted,
        .pendingKYC,
        .provePrefillData,
        .collectKyc
    ]
}

extension OnboardingFlow: WhichFlowSequenceViewController {

    private static let lock: UnfairLock = UnfairLock()
    private var lock: UnfairLock { Self.lock }

    public private(set) static var map: [OnboardingFlow.Slug: (AnyJSON) throws -> FlowSequenceViewController] = [
        .proveMobileAuth: makePendingFlowSequenceViewController, // Missing service
        .displayMessage: makeErrorFlowSequenceViewController,
        .proveChallenge: makeChallengeFlowSequenceViewController, // Split page
        .proveCollectData: makeChallengeFlowSequenceViewController,
        .proveSmsLoading: makeProveSmsLoadingFlowSequenceViewController,
        .proveApplicationSubmitted: makeApplicationSubmittedViewFlowSequenceViewController,
        .pendingKYC: makePendingFlowSequenceViewController,
        .provePrefillData: makePersonalInformationConfirmationFlowSequenceViewController,
        .collectKyc: makeVeriffIntroductionFlowSequenceViewController,
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

func makePendingFlowSequenceViewController(_ metadata: AnyJSON) throws -> FlowSequenceViewController {
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

func makeProveApplicationSubmittedFlowSequenceViewController(_ metadata: AnyJSON) throws -> FlowSequenceViewController {
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

func makeProveSmsLoadingFlowSequenceViewController(_ metadata: AnyJSON) throws -> FlowSequenceViewController {
    FlowSequenceHostingViewController { completion in
        PhoneNumberVerificationView(completion: completion)
    }
}

func makePersonalInformationConfirmationFlowSequenceViewController(_ metadata: AnyJSON) throws -> FlowSequenceViewController {
    @Dependency(\.KYCOnboardingService) var KYCOnboardingService
    return FlowSequenceHostingViewController { completion in
        AsyncContentView(
            source: { try await KYCOnboardingService.lookupPrefill() },
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
            let dialog = try metadata["ux"].decode(UX.Dialog.self)
            let error = Nabu.Error(
                id: OnboardingFlow.Slug.displayMessage.value,
                code: .unknown,
                type: .unknown,
                ux: dialog
            )
            return ErrorView(ux: UX.Error(nabu: error))
        } catch {
            do {
                return try ErrorView(ux: UX.Error(nabu: metadata.decode(Nabu.Error.self)), navigationBarClose: false, dismiss: completion)
            } catch {
                return try ErrorView(ux: UX.Error(error: metadata.as(Error.self)), navigationBarClose: false, dismiss: completion)
            }
        }
    }
}
