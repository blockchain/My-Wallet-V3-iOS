/// Extracted from Introspect library
/// https://github.com/siteline/SwiftUI-Introspect

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

    public init(
        selector: @escaping (IntrospectionUIView) -> TargetViewType?,
        customize: @escaping (TargetViewType) -> Void
    ) {
        self.selector = selector
        self.customize = customize
    }

    public func makeUIView(context: UIViewRepresentableContext<UIKitIntrospection>) -> IntrospectionUIView {
        let view = IntrospectionUIView()
        view.accessibilityIdentifier = "IntrospectionUIView<\(TargetViewType.self)>"
        return view
    }

    public func updateUIView(
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
