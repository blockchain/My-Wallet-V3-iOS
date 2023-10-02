import Blockchain
import ErrorsUI
import SwiftUI
import UIKit

class Service {
    func next() async throws -> OnboardingFlow {
        // fetch client state
        // post to onboarding/flow
        // wait for response, return it
        fatalError()
    }
}

var a: Void {

    let service = Service()
    let s = AsyncStream(
        unfolding: {
            do {
                return try await service.next()
            } catch {
                return OnboardingFlow(
                    slug: .error,
                    metadata: AnyJSON(error)
                )
            }
        }
    )
}

protocol WhichFlowSequenceViewController {
    var metadata: AnyJSON { get }
    func viewController() -> FlowSequenceViewController
}

protocol FlowSequenceViewController: UIViewController {
    func waitForCompletion() async
}

class FlowSequenceHostingViewController<RootView: View>: UIHostingController<RootView>, FlowSequenceViewController {

    private var subject: CurrentValueSubject<Bool, Never>

    init(_ rootViewBuilder: (@escaping () -> Void) throws -> RootView) rethrows {
        let completion = CurrentValueSubject<Bool, Never>(false); do {
            subject = completion
        }
        try super.init(
            rootView: rootViewBuilder { completion.send(true) }
        )
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func waitForCompletion() async {
        for await isCompleted in subject.values {
            if isCompleted { break }
            await Task.yield()
        }
    }
}

@MainActor class FlowSequenceNavigationController<Of: WhichFlowSequenceViewController>: UINavigationController {

    var sequence: AsyncStream<Of>
    var task: Task<Void, Never>? {
        didSet { oldValue?.cancel() }
    }

    init(_ sequence: AsyncStream<Of>) {
        self.sequence = sequence
        super.init(rootViewController: UIHostingController(rootView: InProgressView()))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        task = Task {
            for await which in sequence {
                let viewController = which.viewController()
                pushViewController(viewController, animated: true)
                await viewController.waitForCompletion()
            }
        }
    }
}

// .. Example ..

struct OnboardingFlow: Decodable {
    let slug: OnboardingFlowSlug
    let metadata: AnyJSON
}

struct OnboardingFlowSlug: NewTypeString {
    var value: String
    init(_ value: String) { self.value = value }
}

extension OnboardingFlowSlug {
    static let dateOfBirthChallenge: Self = "PROVE_DOB_CHALLENGE"
    static let error: Self = "ERROR"

    // ...
}

extension OnboardingFlow: WhichFlowSequenceViewController {

    func viewController() -> FlowSequenceViewController {
        do {
            switch slug {
            case .dateOfBirthChallenge:
                return FlowSequenceHostingViewController { completion in
                    DateOfBirthChallengeView(completion: completion)
                }
            case .error:
                return try FlowSequenceHostingViewController { completion in
                    do {
                        return try ErrorView(ux: UX.Error(nabu: metadata.decode(Nabu.Error.self)))
                    } catch {
                        return try ErrorView(ux: UX.Error(error: metadata.as(Error.self)))
                    }
                }
            default:
                return FlowSequenceHostingViewController { _ in ErrorView(ux: .unsupportedFlow) }
            }
        } catch {
            return FlowSequenceHostingViewController { _ in
                ErrorView(ux: UX.Error(error: error))
            }
        }
    }
}


extension UX.Error {
    static let unsupportedFlow = UX.Error(
        id: "unsupported.flow",
        title: "Unsupported flow",
        message: "We encountered a problem, please retry"
    )
}
