import Blockchain

class OnboardingFlowService {

    let client: OnboardingFlowClient

    init(client: OnboardingFlowClient) {
        self.client = client
    }

    func stream() -> AsyncStream<OnboardingFlow> {
        AsyncStream(
            unfolding: { [client] in
                do {
                    return try await client.next()
                } catch {
                    return OnboardingFlow(next_action: .init(slug: .displayMessage, metadata: AnyJSON(error)))
                }
            }
        )
    }
}
