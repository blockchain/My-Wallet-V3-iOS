import SwiftUI
import UIKit

enum DetectSwipeToDismiss {}

extension View {

    /// Calls the passing closure when an interactive dismissal occurs, aka swipe down to dismiss
    @ViewBuilder
    public func onInteractiveDismissal(
        _ closure: @escaping () -> Void
    ) -> some View {
        background(
            DetectSwipeToDismiss.Representable(onDismissal: closure)
        )
    }
}

extension DetectSwipeToDismiss {

    struct Representable: UIViewControllerRepresentable {
        private var onDismissal: () -> Void

        init(onDismissal: @escaping () -> Void) {
            self.onDismissal = onDismissal
        }

        func makeUIViewController(context: Context) -> Controller {
            Controller(onDismissal: onDismissal)
        }

        func updateUIViewController(_ controller: Controller, context: Context) {
            controller.update()
        }
    }

    final class Controller: UIViewController, UIAdaptivePresentationControllerDelegate {
        private var onDismissal: () -> Void
        private weak var _delegate: UIAdaptivePresentationControllerDelegate?

        init(
            onDismissal: @escaping () -> Void
        ) {
            self.onDismissal = onDismissal
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func willMove(toParent parent: UIViewController?) {
            super.willMove(toParent: parent)
            if let controller = parent?.presentationController {
                if controller.delegate !== self {
                    _delegate = controller.delegate
                    controller.delegate = self
                }
            }
        }

        override func responds(to aSelector: Selector!) -> Bool {
            if super.responds(to: aSelector) { return true }
            if _delegate?.responds(to: aSelector) ?? false { return true }
            return false
        }

        func update() {
            if let controller = navigationController?.presentationController {
                controller.delegate = self
            } else {
                parent?.presentationController?.delegate = self
            }
        }

        override func forwardingTarget(for aSelector: Selector!) -> Any? {
            if super.responds(to: aSelector) { return self }
            return _delegate
        }

        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            onDismissal()
        }
    }
}
