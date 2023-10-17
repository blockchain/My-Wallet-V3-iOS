import Blockchain
import BlockchainUI
import ErrorsUI
import SwiftUI
import UIKit

public protocol WhichFlowSequenceViewController {
    func viewController() -> FlowSequenceViewController
}

public protocol FlowSequenceViewController: UIViewController {
    func waitForCompletion() async
}

public class FlowSequenceHostingViewController<RootView: View>: UIHostingController<RootView>, FlowSequenceViewController {

    private var subject: CurrentValueSubject<Bool, Never>

    public init(@ViewBuilder _ rootViewBuilder: (@escaping () -> Void) throws -> RootView) rethrows {
        self.subject = CurrentValueSubject<Bool, Never>(false)
        try super.init(rootView: rootViewBuilder { [subject] in subject.send(true) })
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        _disableSafeArea = true
    }

    public func waitForCompletion() async {
        for await isCompleted in subject.values {
            if isCompleted { break }
            await Task.yield()
        }
    }
}

@MainActor public class FlowSequenceNavigationController<Of: WhichFlowSequenceViewController>: UINavigationController {

    var sequence: AsyncStream<Of>
    var task: Task<Void, Never>? {
        didSet { oldValue?.cancel() }
    }

    public init(_ sequence: AsyncStream<Of>) {
        self.sequence = sequence
        super.init(
            rootViewController: UIHostingController(rootView: InProgressView())
        )
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNavigationBarHidden(true, animated: animated)
        task = Task {
            for await which in sequence {
                let viewController = which.viewController()
                pushViewController(viewController, animated: true)
                await viewController.waitForCompletion()
            }
        }
    }
}

// .. Preview ..

private struct PreviewFlow: Decodable {
    let n: Int
}

private struct PreviewNView: View {

    @State private var isLoading = false
    let n: Int
    let completion: () -> Void

    var body: some View {
        VStack {
            [
                Color.red,
                Color.blue,
                Color.yellow,
                Color.green
            ][n % 4]
        }
        .safeAreaInset(edge: .bottom) {
            PrimaryButton(
                title: "Next (\(n))",
                isLoading: isLoading,
                action: {
                    Task {
                        isLoading = true
                        try await Task.sleep(nanoseconds: (1...3).randomElement()! * NSEC_PER_SEC)
                        completion()
                    }
                }
            )
            .padding()
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.semantic.light.ignoresSafeArea())
    }
}

extension PreviewFlow: WhichFlowSequenceViewController {

    func viewController() -> FlowSequenceViewController {
        FlowSequenceHostingViewController { completion in
            if n == 10 {
                ConfettiCannonView(.init(confetti: [
                    .icon(.blockchain),
                    .icon(.blockchain),
                    .icon(.blockchain.color(.red)),
                    .icon(.blockchain.color(.yellow)),
                    .icon(.blockchain.color(.pink)),
                    .icon(.blockchain.color(.green))
                ])) { fire in
                    PrimaryButton(
                        title: "Party!",
                        action: { fire() }
                    )
                    .padding()
                }
            } else {
                PreviewNView(n: n, completion: completion)
            }
        }
    }
}

private struct PreviewHosting: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> some UIViewController {
        FlowSequenceNavigationController(AsyncStream((1...10).map(PreviewFlow.init(n:)).async))
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

#if compiler(>=5.9)

#Preview {
    PreviewHosting().ignoresSafeArea()
}

#endif
