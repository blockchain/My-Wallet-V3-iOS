// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Public

extension View {

    /// Replacement for setting navigation items using component library styling.
    /// - Parameters:
    ///   - icon: Optional leading icon displayed in the navigation bar
    ///   - title: Optional title displayed in the navigation bar
    ///   - trailing: Trailing views in navigation bar. Commonly `IconButton`, or `TextButton`.
    ///               Multiple views are auto distributed along an HStack.
    /// - Returns: `self`, otherwise unmodified.
    public func primaryNavigation<Leading: View, Trailing: View>(
        @ViewBuilder leading: @escaping () -> Leading,
        title: String? = nil,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) -> some View {
        modifier(
            PrimaryNavigationModifier<Leading, Trailing>(
                leading: leading,
                title: title,
                trailing: trailing
            )
        )
    }

    /// Replacement for setting navigation items using component library styling.
    /// - Parameters:
    ///   - title: Optional title displayed in the navigation bar
    ///   - trailing: Trailing views in navigation bar. Commonly `IconButton`, or `TextButton`.
    ///               Multiple views are auto distributed along an HStack.
    /// - Returns: `self`, otherwise unmodified.
    public func primaryNavigation<Trailing: View>(
        title: String? = nil,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) -> some View {
        modifier(
            PrimaryNavigationModifier<EmptyView, Trailing>(
                leading: nil,
                title: title,
                trailing: trailing
            )
        )
    }

    /// Replacement for setting navigation items using component library styling.
    ///
    /// This function is specifically available for setting the title without changing trailing views.
    ///
    /// - Parameters:
    ///   - icon: Optional leading icon displayed in the navigation bar
    ///   - title: Optional title displayed in the navigation bar
    /// - Returns: `self`, otherwise unmodified.
    public func primaryNavigation<Leading: View>(
        @ViewBuilder leading: @escaping () -> Leading,
        title: String?
    ) -> some View {
        modifier(
            PrimaryNavigationModifier<Leading, EmptyView>(
                leading: leading,
                title: title,
                trailing: nil
            )
        )
    }

    /// Replacement for setting navigation items using component library styling.
    ///
    /// This function is specifically available for setting the title without changing trailing views.
    ///
    /// - Returns: `self`, otherwise unmodified.
    public func primaryNavigation() -> some View {
        modifier(
            PrimaryNavigationModifier<EmptyView, EmptyView>(
                leading: nil,
                title: nil,
                trailing: nil
            )
        )
    }

    /// Replacement for setting navigation items using component library styling.
    ///
    /// This function is specifically available for setting the title without changing trailing views.
    ///
    /// - Parameters:
    ///   - title: Optional title displayed in the navigation bar
    /// - Returns: `self`, otherwise unmodified.
    public func primaryNavigation(
        title: String?
    ) -> some View {
        modifier(
            PrimaryNavigationModifier<EmptyView, EmptyView>(
                leading: nil,
                title: title,
                trailing: nil
            )
        )
    }
}

/// Replacement for `NavigationView` to fix a bug on iPhone
public struct PrimaryNavigationView<Content: View>: View {
    @ViewBuilder private let content: Content

    /// A `NavigationView` with a custom designed navigation bar
    /// - Parameters:
    ///   - content: Content of navigation view. Use `.primaryNavigation(...)` for titles and trailing items, and `PrimaryNavigationLink` for links.
    public init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        #if os(macOS)
        NavigationView {
            content
        }
        #else
        NavigationView {
            content
                .background(NavigationConfigurator())
        }
        // StackNavigationViewStyle is to fix a bug on iPhone where the following
        // console error appears, and the navigation bar goes blank.
        //
        // > [Assert] displayModeButtonItem is internally managed and not exposed for DoubleColumn style. Returning an empty, disconnected UIBarButtonItem to fulfill the non-null contract.
        //
        // If we add iPad layout, we can re-enable other styles conditionally.
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}

/// Replacement for `NavigationLink` which provides some private functionality for detecting
/// being a pushed view in the destination.
public struct PrimaryNavigationLink<Destination: View, Label: View>: View {
    let destination: Destination
    let isActive: Binding<Bool>?
    @ViewBuilder let label: () -> Label

    public init(
        destination: Destination,
        isActive: Binding<Bool>? = nil,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.destination = destination
        self.isActive = isActive
        self.label = label
    }

    public var body: some View {
        if let isActive {
            NavigationLink(
                destination: destination,
                isActive: isActive,
                label: label
            )
        } else {
            NavigationLink(
                destination: destination,
                label: label
            )
        }
    }
}

extension EnvironmentValues {

    /// Accent color for navigation bar back button in `PrimaryNavigation`
    ///
    /// Defaults to `.semantic.primary` (Wallet)
    public var navigationBackButtonColor: Color {
        get { self[NavigationBackButtonColor.self] }
        set { self[NavigationBackButtonColor.self] = newValue }
    }

    /// Accent color for navigation bar in `PrimaryNavigation`
    ///
    /// Defaults to `.semantic.background` (Wallet)
    public var navigationBarColor: Color {
        get { self[NavigationBarColor.self] }
        set { self[NavigationBarColor.self] = newValue }
    }
}

// MARK: - Private

/// Modifier which applies custom navigation bar styling
private struct PrimaryNavigationModifier<Leading: View, Trailing: View>: ViewModifier {

    let leading: (() -> Leading)?
    let title: String?
    let trailing: (() -> Trailing)?

    func body(content: Content) -> some View {
        #if os(macOS)
        content
            .ifLet(title) { view, title in
                view.navigationTitle(title)
            }
            .toolbar {
                ToolbarItem {
                    leading?()
                    trailing?()
                }
            }
        #else
        content
            .navigationBarTitleDisplayMode(.inline)
            .ifLet(title) { view, title in
                view.navigationTitle(title)
            }
            .navigationBarItems(
                leading: HStack(spacing: Spacing.padding3) {
                    leading?()
                },
                trailing: HStack(spacing: Spacing.padding3) {
                    trailing?()
                }
                .accentColor(.semantic.muted)
            )
        #endif
    }
}

/// Environment key set by `PrimaryNavigation`
private struct NavigationBackButtonColor: EnvironmentKey {
    static var defaultValue = Color.semantic.primary
}

/// Environment key set by `PrimaryNavigation`
private struct NavigationBarColor: EnvironmentKey {
    static var defaultValue = Color.semantic.background
}

#if canImport(UIKit)
public private(set) var currentNavigationController: UINavigationController?

public class PrimaryNavigationViewController: UINavigationController {

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currentNavigationController = navigationController
    }
}

/// Customizing `UINavigationController` without using `UIAppearance`
private struct NavigationConfigurator: UIViewControllerRepresentable {

    @Environment(\.navigationBackButtonColor) var navigationBackButtonColor
    @Environment(\.navigationBarColor) var navigationBarColor

    func makeUIViewController(context: Context) -> NavigationConfiguratorViewController {
        NavigationConfiguratorViewController(
            navigationBackButtonColor: navigationBackButtonColor,
            navigationBarColor: navigationBarColor
        )
    }

    func updateUIViewController(_ uiViewController: NavigationConfiguratorViewController, context: Context) {
        uiViewController.navigationBackButtonColor = navigationBackButtonColor
        uiViewController.navigationBarColor = navigationBarColor
    }

    final class NavigationConfiguratorViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

        var navigationBackButtonColor: Color {
            didSet { styleNavigationBar() }
        }

        var navigationBarColor: Color {
            didSet { styleNavigationBar() }
        }

        init(navigationBackButtonColor: Color, navigationBarColor: Color) {
            self.navigationBackButtonColor = navigationBackButtonColor
            self.navigationBarColor = navigationBarColor
            super.init(nibName: nil, bundle: nil)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            currentNavigationController = navigationController
        }

        // Must wait until the view controller is added to the hierarchy to customize the navigation bar.
        // Otherwise `navigationController?` is nil.
        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)

            if let navigationItem = parent?.navigationItem {
                navigationItem.backButtonDisplayMode = .minimal
            }
            styleNavigationBar()

            guard navigationController?.delegate !== self else {
                return
            }
            __proxy = __proxy ?? navigationController?.delegate
            navigationController?.delegate = self
            navigationController?.interactivePopGestureRecognizer?.delegate = self
        }

        func styleChildViewController(_ viewController: UIViewController) {
            // Hide the back button title
            viewController.navigationItem.backButtonDisplayMode = .minimal
        }

        // Customize the styling of the navigation bar
        private func styleNavigationBar() {
            if let navigationBar = navigationController?.navigationBar {

                navigationBar.tintColor = UIColor(
                    Color(
                        light: .palette.grey400,
                        dark: .palette.grey400
                    )
                )
                navigationBar.barTintColor = UIColor(navigationBarColor)
                navigationBar.backgroundColor = UIColor(navigationBarColor)

                let image = Icon.chevronLeft.uiImage?
                    .padded(by: UIEdgeInsets(top: 0, left: Spacing.padding1, bottom: 0, right: 0))

                navigationBar.backIndicatorImage = image
                navigationBar.backIndicatorTransitionMaskImage = image
                navigationBar.tintColor = UIColor(navigationBackButtonColor)

                navigationBar.largeTitleTextAttributes = [
                    .foregroundColor: UIColor(.semantic.title),
                    .font: Typography.title2.uiFont as Any
                ]

                navigationBar.titleTextAttributes = [
                    .foregroundColor: UIColor(.semantic.title),
                    .font: Typography.title3.uiFont as Any
                ]

                UITableView.appearance().backgroundColor = .clear
            }
        }

        weak var __proxy: UINavigationControllerDelegate?

        func navigationController(
            _ navigationController: UINavigationController,
            willShow viewController: UIViewController,
            animated: Bool
        ) {
            __proxy?.navigationController?(navigationController, willShow: viewController, animated: animated)
            styleChildViewController(viewController)
        }

        func navigationController(
            _ navigationController: UINavigationController,
            didShow viewController: UIViewController,
            animated: Bool
        ) {
            __proxy?.navigationController?(navigationController, didShow: viewController, animated: animated)
        }

        func navigationControllerSupportedInterfaceOrientations(
            _ navigationController: UINavigationController
        ) -> UIInterfaceOrientationMask {
            __proxy?.navigationControllerSupportedInterfaceOrientations?(navigationController) ?? .all
        }

        func navigationControllerPreferredInterfaceOrientationForPresentation(
            _ navigationController: UINavigationController
        ) -> UIInterfaceOrientation {
            __proxy?.navigationControllerPreferredInterfaceOrientationForPresentation?(
                navigationController
            ) ?? .portrait
        }

        func navigationController(
            _ navigationController: UINavigationController,
            interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
        ) -> UIViewControllerInteractiveTransitioning? {
            __proxy?.navigationController?(navigationController, interactionControllerFor: animationController)
        }

        func navigationController(
            _ navigationController: UINavigationController,
            animationControllerFor operation: UINavigationController.Operation,
            from fromVC: UIViewController,
            to toVC: UIViewController
        ) -> UIViewControllerAnimatedTransitioning? {
            __proxy?.navigationController?(
                navigationController,
                animationControllerFor: operation,
                from: fromVC,
                to: toVC
            )
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            (navigationController?.viewControllers.count ?? 0) > 1
        }
    }
}
#endif

// MARK: - Previews

struct PrimaryNavigation_Previews: PreviewProvider {
    static var previews: some View {
        PreviewContainer()
            .previewDisplayName("Wallet")

        PreviewContainer()
            .environment(\.navigationBackButtonColor, Color(light: .palette.dark400, dark: .palette.white))
            .previewDisplayName("Exchange")
    }

    struct PreviewContainer: View {
        @State var isActive: Bool = false

        var body: some View {
            PrimaryNavigationView {
                primary
            }
        }

        @ViewBuilder var primary: some View {
            PrimaryNavigationLink(
                destination: secondary,
                isActive: $isActive,
                label: { Text("Foo") }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.green)
            .primaryNavigation(
                leading: {
                    IconButton(icon: .user) {}
                },
                title: "Foo",
                trailing: {
                    IconButton(icon: .qrCode) {}
                }
            )
        }

        @ViewBuilder var secondary: some View {
            ScrollView {
                LazyVStack {
                    ForEach(0..<100, id: \.self) { value in
                        Text("\(value)")
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                    }
                }
            }
            .primaryNavigation(title: "Bar") {
                IconButton(icon: .chat) {}
            }
        }
    }
}
