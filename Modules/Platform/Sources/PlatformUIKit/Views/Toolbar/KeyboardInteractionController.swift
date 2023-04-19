// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

/// A `UIToolbar` provider that embeds toolbar setup.
/// Typically used in screens that contain keyboard input.
public final class KeyboardInteractionController {

    // MARK: - Types

    private enum Parent {
        case view(UnretainedContentBox<UIView>)
        case viewController(UnretainedContentBox<UIViewController>)

        var value: UIView? {
            switch self {
            case .view(let value):
                return value.value
            case .viewController(let value):
                return value.value?.view
            }
        }
    }

    // MARK: - Public Properties

    public private(set) var toolbar: UIToolbar?

    // MARK: - Private Properties

    private let parent: Parent
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public convenience init(in viewController: UIViewController, disablesToolBar: Bool = false) {
        let parent = Parent.viewController(UnretainedContentBox(viewController))
        self.init(using: parent, disablesToolBar: disablesToolBar)
    }

    public convenience init(in view: UIView, disablesToolBar: Bool = false) {
        let parent = Parent.view(UnretainedContentBox(view))
        self.init(using: parent, disablesToolBar: disablesToolBar)
    }

    private init(using parent: Parent, disablesToolBar: Bool) {
        self.parent = parent
        if !disablesToolBar {
            setupToolbar()
        }
        setupTapGestureRecognizer()
    }

    private func setupToolbar() {
        let toolbar = UIToolbar()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        self.toolbar = toolbar
    }

    private func setupTapGestureRecognizer() {
        guard let view = parent.value else { return }
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.rx.event
            .bind { [unowned self] _ in
                dismissKeyboard()
            }
            .disposed(by: disposeBag)
    }

    @objc
    public func dismissKeyboard() {
        parent.value?.endEditing(true)
    }
}

// MARK: - ObservableType

extension ObservableType {
    public func dismissKeyboard(using controller: KeyboardInteractionController) -> Observable<Element> {
        self.do(onNext: { _ in
            controller.dismissKeyboard()
        })
    }
}
