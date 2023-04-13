// Extracted from Introspect library
// https://github.com/siteline/SwiftUI-Introspect

#if canImport(UIKit)

import SwiftUI
import UIKit

class IntrospectionUIView: UIView {

    required init() {
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        isHidden = true
        isUserInteractionEnabled = false
    }
}

struct UIKitIntrospection<TargetViewType: UIView>: UIViewRepresentable {

    let selector: (IntrospectionUIView) -> TargetViewType?

    let customize: (TargetViewType) -> Void

    init(
        selector: @escaping (IntrospectionUIView) -> TargetViewType?,
        customize: @escaping (TargetViewType) -> Void
    ) {
        self.selector = selector
        self.customize = customize
    }

    func makeUIView(context: UIViewRepresentableContext<UIKitIntrospection>) -> IntrospectionUIView {
        let view = IntrospectionUIView()
        view.accessibilityIdentifier = "IntrospectionUIView<\(TargetViewType.self)>"
        return view
    }

    func updateUIView(
        _ uiView: IntrospectionUIView,
        context: UIViewRepresentableContext<UIKitIntrospection>
    ) {
        DispatchQueue.main.async {
            guard let targetView = selector(uiView) else {
                return
            }
            customize(targetView)
        }
    }
}

class IntrospectionUIViewController: UIViewController {
    required init() {
        super.init(nibName: nil, bundle: nil)
        view = IntrospectionUIView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct UIKitIntrospectionViewController<TargetViewControllerType: UIViewController>: UIViewControllerRepresentable {

    let selector: (IntrospectionUIViewController) -> TargetViewControllerType?
    let customize: (TargetViewControllerType) -> Void

    init(
        selector: @escaping (UIViewController) -> TargetViewControllerType?,
        customize: @escaping (TargetViewControllerType) -> Void
    ) {
        self.selector = selector
        self.customize = customize
    }

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<UIKitIntrospectionViewController>
    ) -> IntrospectionUIViewController {
        let viewController = IntrospectionUIViewController()
        viewController.accessibilityLabel = "IntrospectionUIViewController<\(TargetViewControllerType.self)>"
        viewController.view.accessibilityLabel = "IntrospectionUIView<\(TargetViewControllerType.self)>"
        return viewController
    }

    func updateUIViewController(
        _ uiViewController: IntrospectionUIViewController,
        context: UIViewControllerRepresentableContext<UIKitIntrospectionViewController>
    ) {
        DispatchQueue.main.async {
            guard let targetView = selector(uiViewController) else {
                return
            }
            customize(targetView)
        }
    }
}

#endif
