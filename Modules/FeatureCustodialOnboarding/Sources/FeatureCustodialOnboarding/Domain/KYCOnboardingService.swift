import Blockchain

public class KYCOnboardingService {

    @Dependency(\.app) var app

    let flowClient: OnboardingFlowClient
    let proveClient: ProveClient

    public init(
        flowClient: OnboardingFlowClient,
        proveClient: ProveClient
    ) {
        self.flowClient = flowClient
        self.proveClient = proveClient
    }

    public func flow() -> AsyncStream<OnboardingFlow> {
        AsyncStream(
            unfolding: { [flowClient] in
                do {
                    return try await flowClient.next()
                } catch let error as Nabu.Error where error.response?.statusCode == 204 {
                    return nil
                } catch {
                    return OnboardingFlow(next_action: .init(slug: .displayMessage, metadata: AnyJSON(error)))
                }
            }
        )
    }

    public func requestInstantLink(
        mobileNumber: String,
        last4Ssn: String?,
        dateOfBirth: Date?
    ) async throws {
        guard let dateOfBirth else {
            return try await proveClient.requestInstantLink(
                mobileNumber: mobileNumber,
                dateOfBirth: nil,
                last4Ssn: last4Ssn
            )
        }
        return try await proveClient.requestInstantLink(
            mobileNumber: mobileNumber,
            dateOfBirth: dobFormatter.string(from: dateOfBirth),
            last4Ssn: nil
        )
    }

    public func requestInstantLinkResend() async throws {
        try await proveClient.requestInstantLinkResend()
    }

    public func instantLink() async throws -> InstantLink {
        try await proveClient.instantLink()
    }

    let dobFormatter = with(DateFormatter()) { dateFormatter in
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .short
    }

    public func challenge(dateOfBirth: Date) async throws -> Challenge {
        try await challenge(dateOfBirth: dobFormatter.string(from: dateOfBirth), last4Ssn: nil)
    }

    public func challenge(dateOfBirth: String?, last4Ssn: String?) async throws -> Challenge {
        let challenge = try await proveClient.challenge(dateOfBirth: dateOfBirth, last4Ssn: last4Ssn)
        try await app.transaction { app in
            try await app.set(blockchain.ux.kyc.prove.challenge.prefill.info, to: challenge.prefill.json())
        }
        return challenge
    }

    public func confirm(_ personalInformation: PersonalInformation) async throws -> Ownership {
        try await proveClient.confirm(personalInformation: personalInformation)
    }

    public func lookupPrefill() async throws -> PersonalInformation {
        try await proveClient.lookupPrefill()
    }
}

public struct KYCOnboardingServiceDependencyKey: DependencyKey {

    public static var liveValue: KYCOnboardingService = KYCOnboardingService(
        flowClient: OnboardingFlowClient(),
        proveClient: ProveClient()
    )
}

extension DependencyValues {

    public var KYCOnboardingService: KYCOnboardingService {
        get { self[KYCOnboardingServiceDependencyKey.self] }
        set { self[KYCOnboardingServiceDependencyKey.self] = newValue }
    }
}
