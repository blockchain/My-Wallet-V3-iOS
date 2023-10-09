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
        .error: makeErrorFlowSequenceViewController
    ]
    
    public static func register(_ slug: OnboardingFlow.Slug, _ builder: @escaping (AnyJSON) throws -> FlowSequenceViewController) {
        lock.withLock { map[slug] = builder }
    }

    public func viewController() -> FlowSequenceViewController {
        do {
            if let viewController = lock.withLock(body: { Self.map[next_action.slug] }) {
                return try viewController(next_action.metadata)
            } else {
                throw "\(next_action.slug.value) has no associated view"
            }
        } catch {
            return FlowSequenceHostingViewController { completion in
                ErrorView(ux: UX.Error(error: error))
            }
        }
    }
}

/* Defaults */

func makeErrorFlowSequenceViewController(_ metadata: AnyJSON) throws -> FlowSequenceViewController {
    return try FlowSequenceHostingViewController { completion in
        do {
            return try ErrorView(ux: UX.Error(nabu: metadata.decode(Nabu.Error.self)))
        } catch {
            return try ErrorView(ux: UX.Error(error: metadata.as(Error.self)))
        }
    }
}
