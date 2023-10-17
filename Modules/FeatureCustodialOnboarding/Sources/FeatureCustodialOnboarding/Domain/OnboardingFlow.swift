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
    public static let proveDateOfBirthChallenge: Self = "PROVE_DOB_CHALLENGE"
    public static let provePhoneNumberEntry: Self = "PROVE_PHONE_NUMBER_ENTRY"
    public static let provePhoneNumberVerification: Self = "PROVE_PHONE_NUMBER_VERIFICATION"
    public static let verificationInProgress: Self = "VERIFICATION_IN_PROGRESS"
    public static let loading: Self = "LOADING"
    public static let veriff: Self = "VERIFF"
    public static let error: Self = "ERROR"
}

extension OnboardingFlow.Slug: CaseIterable {
    public static var allCases: [OnboardingFlow.Slug] = [.prove, .veriff, .error]
}

extension OnboardingFlow: WhichFlowSequenceViewController {

    private static let lock: UnfairLock = UnfairLock()
    private var lock: UnfairLock { Self.lock }

    public private(set) static var map: [OnboardingFlow.Slug: (AnyJSON) throws -> FlowSequenceViewController] = [
        .error: makeErrorFlowSequenceViewController,
        .proveDateOfBirthChallenge: makeDateOfBirthChallengeFlowSequenceViewController,
        .provePhoneNumberEntry: makePhoneNumberEntryFlowSequenceViewController,
        .provePhoneNumberVerification: makePhoneNumberVerificationFlowSequenceViewController,
        .verificationInProgress: makeVerificationInProgressFlowSequenceViewController,
        .loading: makeInProgressFlowSequenceViewController
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
            return FlowSequenceHostingViewController { _ in
                ErrorView(ux: UX.Error(error: error))
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

func makePhoneNumberEntryFlowSequenceViewController(_ metadata: AnyJSON) throws -> FlowSequenceViewController {
    FlowSequenceHostingViewController { completion in
        PhoneNumberEntryView(completion: completion)
    }
}

func makePhoneNumberVerificationFlowSequenceViewController(_ metadata: AnyJSON) throws -> FlowSequenceViewController {
    FlowSequenceHostingViewController { completion in
        PhoneNumberVerificationView(completion: completion)
    }
}

func makeDateOfBirthChallengeFlowSequenceViewController(_ metadata: AnyJSON) throws -> FlowSequenceViewController {
    FlowSequenceHostingViewController { completion in
        DateOfBirthChallengeView(completion: completion)
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
    try FlowSequenceHostingViewController { _ in
        do {
            return try ErrorView(ux: UX.Error(nabu: metadata.decode(Nabu.Error.self)))
        } catch {
            return try ErrorView(ux: UX.Error(error: metadata.as(Error.self)))
        }
    }
}
