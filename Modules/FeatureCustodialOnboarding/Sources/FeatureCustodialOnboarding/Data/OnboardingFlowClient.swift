import NetworkKit

class OnboardingFlowClient {

    let adapter: NetworkAdapterAPI
    let requestBuilder: RequestBuilder

    init(adapter: NetworkAdapterAPI, requestBuilder: RequestBuilder) {
        self.adapter = adapter
        self.requestBuilder = requestBuilder
    }

    func next() async throws -> OnboardingFlow {
        try await adapter.perform(
            request: requestBuilder.post(
                path: "/onboarding/flow/next",
                body: [
                    "slugs": OnboardingFlow.Slug.allCases
                ].json()
            )
            .or(throw: "Could not build request to /onboarding/flow/next".error())
        )
        .await()
    }
}
