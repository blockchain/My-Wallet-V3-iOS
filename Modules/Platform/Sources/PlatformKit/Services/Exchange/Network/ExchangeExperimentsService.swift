import Combine
import DIKit
import RxSwift
import ToolKit

public struct ExchangeWalletAwarenessResponse {
    public let cohort: Int
    public var isEnabled: Bool { cohort >= 1 }

    public init(cohort: Int) {
        self.cohort = cohort
    }
}

public protocol ExchangeExperimentsServiceAPI {
    var walletAwarenessResponse: AnyPublisher<ExchangeWalletAwarenessResponse, Never> { get }
}

public final class ExchangeExperimentsService: ExchangeExperimentsServiceAPI {
    private let client: ExchangeExperimentsClientAPI

    init(client: ExchangeExperimentsClientAPI = resolve()) {
        self.client = client
    }

    public var walletAwarenessResponse: AnyPublisher<ExchangeWalletAwarenessResponse, Never> {
        client.getWalletAwarenessCohort()
            .map { ExchangeWalletAwarenessResponse(cohort: $0.walletAwarenessPrompt) }
            .catch { _ in
                Just(ExchangeWalletAwarenessResponse(cohort: 0))
            }
            .eraseToAnyPublisher()
    }
}
