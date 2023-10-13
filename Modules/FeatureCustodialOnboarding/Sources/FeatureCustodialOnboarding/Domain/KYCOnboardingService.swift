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
                } catch {
                    return OnboardingFlow(next_action: .init(slug: .error, metadata: AnyJSON(error)))
                }
            }
        )
    }

    public func requestInstantLink(mobileNumber: String) async throws {
        try await proveClient.requestInstantLink(mobileNumber: mobileNumber)
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
        try await challenge(dateOfBirth: dobFormatter.string(from: dateOfBirth))
    }

    public func challenge(dateOfBirth: String) async throws -> Challenge {
        let challenge = try await proveClient.challenge(dateOfBirth: dateOfBirth)
        try await app.transaction { app in
            try await app.set(blockchain.ux.kyc.prove.challenge.prefill.id, to: challenge.prefill.prefillId)
            try await app.set(blockchain.ux.kyc.prove.challenge.prefill.info, to: challenge.prefill.json())
        }
        return challenge
    }

    public func confirm(_ personalInformation: PersonalInformation) async throws -> Ownership {
        try await proveClient.confirm(personalInformation: personalInformation)
    }

    public func reject(_ personalInformation: PersonalInformation) async throws -> Ownership {
        try await proveClient.reject(personalInformation: personalInformation)
    }

    public func lookupPrefill(id: String) async throws -> PersonalInformation {
        try await proveClient.lookupPrefill(id: id)
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
