import Blockchain
import NetworkKit

public class OnboardingFlowClient {

    @Dependency(\.networkAdapter) var adapter
    @Dependency(\.requestBuilder) var requestBuilder

    public init() {}

    public func next() async throws -> OnboardingFlow {
        try await adapter.perform(
            request: requestBuilder.post(
                path: "/onboarding/flow/next",
                body: [
                    "slugs": OnboardingFlow.Slug.allCases.map(\.value)
                ].json()
            )
            .or(throw: "Could not build request to /onboarding/flow/next".error())
        )
        .await()
    }
}

extension OnboardingFlowClient {

    class Stub: OnboardingFlowClient {
        let value: () throws -> OnboardingFlow
        init(value: @escaping () throws -> OnboardingFlow) {
            self.value = value
        }

        override func next() async throws -> OnboardingFlow {
            try value()
        }
    }
}
