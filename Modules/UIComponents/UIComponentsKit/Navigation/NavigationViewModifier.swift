// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public enum NavigationButton {
    case back
    case close

    private var iconName: String {
        switch self {
        case .back:
            return "back_chevron_icon"
        case .close:
            return "cancel_icon"
        }
    }
}

extension NavigationButton {

    public func button(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(iconName, bundle: Bundle.UIComponents)
                .renderingMode(.original)
        }
    }
}

extension View {

    public func whiteNavigationBarStyle() -> some View {
        configureNavigationBar {
            $0.navigationBar.prefersLargeTitles = false
            $0.navigationBar.barTintColor = .white
            $0.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.semantic.title
            ]
            $0.navigationBar.tintColor = UIColor.blue600
            $0.navigationBar.shadowImage = UIImage() // remove shadow
        }
    }

    public func lightNavigationBarStyle() -> some View {
        configureNavigationBar {
            $0.navigationBar.prefersLargeTitles = false
            $0.navigationBar.barTintColor = UIColor(Color.semantic.light)
            $0.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.semantic.title
            ]
            $0.navigationBar.tintColor = UIColor.blue600
            $0.navigationBar.shadowImage = UIImage() // remove shadow
        }
    }

    public func largeInlineNavigationBarTitle() -> some View {
        configureNavigationBar {
            $0.navigationBar.titleTextAttributes = [
                .font: UIFont.main(.medium, 20)
            ]
        }
    }

    public func hideBackButtonTitle() -> some View {
        configureNavigationBar {
            $0.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(
                title: "",
                style: .plain,
                target: nil,
                action: nil
            )
        }
    }

    public func leadingNavigationButton(
        _ navigationButton: NavigationButton,
        action: @escaping () -> Void
    ) -> some View {
        navigationBarItems(
            leading: HStack {
                navigationButton.button(action: action)
            }
        )
    }

    public func trailingNavigationButton(
        _ navigationButton: NavigationButton,
        action: @escaping () -> Void
    ) -> some View {
        navigationBarItems(
            trailing: HStack {
                navigationButton.button(action: action)
            }
        )
    }

    public func removeNavigationBarItems() -> some View {
        navigationBarItems(leading: EmptyView(), trailing: EmptyView())
    }
}

// iOS 13 workaround to customize the background for NavigationView
// Source: https://stackoverflow.com/a/62785462
extension View {
    func configureNavigationBar(configure: @escaping (UINavigationController) -> Void) -> some View {
        modifier(NavigationConfigurationViewModifier(configure: configure))
    }
}

struct NavigationConfigurationViewModifier: ViewModifier {
    let configure: (UINavigationController) -> Void

    func body(content: Content) -> some View {
        content.background(NavigationConfigurator(configure: configure))
    }
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    let configure: (UINavigationController) -> Void

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<NavigationConfigurator>
    ) -> NavigationConfigurationViewController {
        NavigationConfigurationViewController(configure: configure)
    }

    func updateUIViewController(
        _ uiViewController: NavigationConfigurationViewController,
        context: UIViewControllerRepresentableContext<NavigationConfigurator>
    ) {}
}

final class NavigationConfigurationViewController: UIViewController {
    let configure: (UINavigationController) -> Void

    init(configure: @escaping (UINavigationController) -> Void) {
        self.configure = configure
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let navigationController {
            configure(navigationController)
        }
    }
}
