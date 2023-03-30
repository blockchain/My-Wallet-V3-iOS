// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import FeatureStakingUI

// MARK: Navigation

@available(iOS 15, *)
extension SuperAppRootController {

    struct NavigationError: Error, CustomStringConvertible {
        static var noTopMostViewController: NavigationError = .init(message: "Unable to determine the top most view controller.")
        static var noNavigationController: NavigationError = .init(message: "No UINavigationController is associated with the top most view controller")
        let message: String
        var description: String { message }
    }

    func getTopMostViewController() throws -> UIViewController {
        guard let viewController = topMostViewController else {
            throw NavigationError.noTopMostViewController
        }
        return viewController
    }

    func present(_ vc: UIViewController, animated: Bool = true) throws {
        let animated = (vc as? DetentPresentingViewController) == nil
        try getTopMostViewController()
            .present(vc, animated: animated)
    }

    func push(_ vc: UIViewController, animated: Bool = true) throws {
        try (currentNavigationController ?? getTopMostViewController().navigationController)
            .or(throw: NavigationError.noNavigationController)
            .pushViewController(vc, animated: animated)
    }

    func dismissTop(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let top = topMostViewController else { return }
        if top.isBeingDismissed {
            app.post(error: NavigationError.isBeingDismissedError(top))
        }
        top.dismiss(animated: animated, completion: completion)
    }

    func pop(animated: Bool = true) {
        (currentNavigationController ?? topMostViewController?.navigationController)?
            .popViewController(animated: animated)
    }

    func dismissAll(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let top = presentedViewController else { return }
        if top.isBeingDismissed {
            app.post(error: NavigationError.isBeingDismissedError(top))
        }
        top.dismiss(animated: animated, completion: completion)
    }
}

@available(iOS 15, *)
extension SuperAppRootController {

    func setupNavigationObservers() {
        app.on(blockchain.ui.type.action.then.navigate.to)
            .receive(on: DispatchQueue.main)
            .sink(to: SuperAppRootController.navigate(to:), on: self)
            .store(in: &bag)

        app.on(blockchain.ui.type.action.then.enter.into)
            .receive(on: DispatchQueue.main)
            .sink(to: SuperAppRootController.enter(into:), on: self)
            .store(in: &bag)

        app.on(blockchain.ui.type.action.then.close)
            .receive(on: DispatchQueue.main)
            .sink(to: SuperAppRootController.close, on: self)
            .store(in: &bag)

        app.on(blockchain.ui.type.action.then.replace.current.stack)
            .receive(on: DispatchQueue.main)
            .sink(to: SuperAppRootController.replaceCurrent(stack:), on: self)
            .store(in: &bag)

        app.on(blockchain.ui.type.action.then.replace.root.stack)
            .receive(on: DispatchQueue.main)
            .sink(to: SuperAppRootController.replaceRoot(stack:), on: self)
            .store(in: &bag)

        app.on(blockchain.ux.home.return.home)
            .receive(on: DispatchQueue.main)
            .sink(to: SuperAppRootController.dismissAll, on: self)
            .store(in: &bag)
    }

    private func hostingController(from event: Session.Event) throws -> UIViewController {
        guard let action = event.action else {
            throw NavigationError(message: "received \(event.reference) without an action")
        }
        return try hostingController(
            from: action.data.decode(Tag.Reference.self),
            in: event.context
        )
    }

    private func hostingControllers(from event: Session.Event) throws -> [UIViewController] {
        guard let action = event.action else {
            throw NavigationError(message: "received \(event.reference) without an action")
        }
        return try action.data.decode([Tag.Reference].self).map {
            try hostingController(
                from: $0,
                in: event.context
            )
        }
    }

    private func hostingController(
        from story: Tag.Reference,
        in context: Tag.Context
    ) throws -> UIViewController {
        var detentWrapperController: DetentPresentingViewController?
        let viewController = try InvalidateDetentsHostingController(
            rootView: siteMap.view(for: story.in(app), in: context)
                .app(app)
                .context(context + story.context)
                .onAppear { [app] in
                    app.post(event: story, context: context)
                }
        )

        if
            let sheet = viewController.sheetPresentationController,
            let presentation = viewController.presentationController
        {
            var grabberVisibleByDefault = true
            if let detents = try? context.decode(blockchain.ui.type.action.then.enter.into.detents, as: [Tag].self) {
                // prepare wrapper controller
                detentWrapperController = .init(presentViewController: viewController)
                detentWrapperController?.modalPresentationStyle = .overFullScreen
                detentWrapperController?.modalTransitionStyle = .crossDissolve
                sheet.detents = detents.reduce(into: [UISheetPresentationController.Detent]()) { detents, tag in
                    switch tag {
                    case blockchain.ui.type.action.then.enter.into.detents.large:
                        grabberVisibleByDefault = false
                        detents.append(.large())
                    case blockchain.ui.type.action.then.enter.into.detents.medium:
                        detents.append(.medium())
                    case blockchain.ui.type.action.then.enter.into.detents.small:
                        detents.append(
                            .heightWithContext(
                                context: { _ in CGRect.screen.height / 4 }
                            )
                        )
                    case blockchain.ui.type.action.then.enter.into.detents.automatic.dimension:
                        viewController.shouldInvalidateDetents = true
                        detents.append(
                            .heightWithContext(
                                context: { [unowned presentation] context in resolution(presentation, context) }
                            )
                        )
                    case _:
                        return
                    }
                }

                if detents.isNotEmpty {
                    let grabberVisible = try? context.decode(blockchain.ui.type.action.then.enter.into.grabber.visible, as: Bool.self)
                    sheet.prefersGrabberVisible = grabberVisible ?? grabberVisibleByDefault
                }
            }
        }

        return detentWrapperController ?? viewController
    }

    func navigate(to event: Session.Event) {
        do {
            try push(hostingController(from: event))
        } catch {
            app.post(error: error)
        }
    }

    func enter(into event: Session.Event) {
        do {
            var vc = try hostingController(from: event)
        out:
            if vc.navigationController == nil {
                let embedToNav = (try? event.context.decode(
                    blockchain.ui.type.action.then.enter.into.embed.in.navigation,
                    as: Bool.self
                )) ?? true
                guard embedToNav, !event.isSafariStory else {
                    break out
                }
                if let detentVC = vc as? DetentPresentingViewController {
                    // detents only exist on `presentViewController` of a `DetentPresentingViewController`
                    let activeVC = detentVC.presentViewController
                    if let sheet = activeVC.sheetPresentationController,
                       sheet.detents != [.large()], sheet.detents.isNotEmpty
                    {
                        break out
                    }
                }
                vc = PrimaryNavigationViewController(rootViewController: vc)
            }
            try present(vc)
        } catch {
            app.post(error: error)
        }
    }

    func replaceRoot(stack event: Session.Event) {
        do {
            let controllers = try hostingControllers(from: event)
            let navigationController = try navigationController
                .or(throw: NavigationError.noNavigationController)
            dismiss(animated: true) {
                navigationController.setViewControllers(controllers, animated: true)
            }
        } catch {
            app.post(error: error)
        }
    }

    func replaceCurrent(stack event: Session.Event) {
        do {
            try (currentNavigationController ?? topMostViewController?.navigationController)
                .or(throw: NavigationError.noNavigationController)
                .setViewControllers(hostingControllers(from: event), animated: true)
        } catch {
            app.post(error: error)
        }
    }

    func close(_ event: Session.Event) {
        do {
            if let close = try? app.state.get(event.reference) as Session.State.Function {
                try close()
            } else {
                dismissTop()
            }
        } catch {
            app.post(error: error)
        }
    }

    func dismissAll(_ event: Session.Event) {
        dismissAll()
    }
}

@available(iOS 15, *)
extension SuperAppRootController.NavigationError {
    static func isBeingDismissedError(_ controller: UIViewController) -> Self {
        Self(
            message: "Attempt to dismiss from view controller \(controller) while a dismiss is in progress!"
        )
    }
}

// MARK: - Helpers

@available(iOS 15.0, *)
let resolution: (UIPresentationController, NSObjectProtocol) -> CGFloat = { presentationController, _ in
    guard let containerView = presentationController.containerView else {
        let idealHeight = presentationController.presentedViewController.view.intrinsicContentSize.height.rounded(.up)
        return idealHeight
    }
    var width = min(presentationController.presentedViewController.view.frame.width, containerView.frame.width)
    if width == 0 {
        width = containerView.frame.width
    }
    var height = presentationController.presentedViewController.view
        .systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingExpandedSize.height))
        .height
    if height == 0 || height > containerView.frame.height {
        height = presentationController.presentedViewController.view.intrinsicContentSize.height
    }
    let idealHeight = (height - presentationController.presentedViewController.view.safeAreaInsets.bottom).rounded(.up)
    return min(idealHeight, containerView.frame.height)
}

private protocol InformingDismissableController {
    var didDismiss: (() -> Void)? { get set }
}

class InvalidateDetentsHostingController<V: View>: UIHostingController<V>, InformingDismissableController {

    var shouldInvalidateDetents = false

    var didDismiss: (() -> Void)?

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if #available(iOS 15.0, *) {
            if shouldInvalidateDetents, let sheet = viewController.sheetPresentationController {
                sheet.performDetentInvalidation()
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let navVC = navigationController {
            handleDismissal(vc: navVC)
        } else {
            handleDismissal(vc: self)
        }
    }

    private func handleDismissal(vc: UIViewController) {
        if vc.isBeingDismissed || vc.isMovingToParent {
            didDismiss?()
        }
    }
}

private class DetentPresentingViewController: UIHostingController<EmptyDetentView>, UIAdaptivePresentationControllerDelegate {

    let presentViewController: UIViewController

    init(presentViewController: UIViewController) {
        self.presentViewController = presentViewController
        super.init(rootView: EmptyDetentView())
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presentViewController.presentationController?.delegate = self
        view.backgroundColor = .clear
        if var controller = presentViewController as? InformingDismissableController {
            controller.didDismiss = { [weak self] in
                self?.dismiss(animated: false)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        present(presentViewController, animated: true)
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        dismiss(animated: false)
    }
}

private struct EmptyDetentView: View {
    var body: some View {
        Color.clear
    }
}

extension Session.Event {

    var isSafariStory: Bool {
        guard let action else { return false }
        do {
            return try action.data.decode(Tag.Reference.self).tag.is(blockchain.ux.web)
        } catch {
            return false
        }
    }
}
