import BlockchainNamespace
import Combine
import Foundation
import ToolKit
import UIKit

final class ApplicationStateObserver: Client.Observer {

    unowned let app: AppProtocol
    let notificationCenter: NotificationCenter

    init(app: AppProtocol, notificationCenter: NotificationCenter = .default) {
        self.app = app
        self.notificationCenter = notificationCenter
    }

    var didEnterBackgroundNotification, willEnterForegroundNotification, willResignActiveNotification: AnyCancellable?
    var bag: Set<AnyCancellable> = []

    func start() {

        app.state.transaction { state in

            state.set(blockchain.app.deep_link.dsl.is.enabled, to: BuildFlag.isInternal)

            state.set(blockchain.app.environment, to: BuildFlag.isInternal ? blockchain.app.environment.debug[] : blockchain.app.environment.production[])
            state.set(blockchain.app.launched.at.time, to: Date())
            state.set(blockchain.app.is.first.install, to: (try? state.get(blockchain.app.number.of.launches)).or(0) == 0)
            state.set(blockchain.app.number.of.launches, to: (try? state.get(blockchain.app.number.of.launches)).or(0) + 1)

            state.set(blockchain.ui.device.id, to: UIDevice.current.identifierForVendor?.uuidString)
            state.set(blockchain.ui.device.os.name, to: UIDevice.current.systemName)
            state.set(blockchain.ui.device.os.version, to: UIDevice.current.systemVersion)
            state.set(blockchain.ui.device.locale.language.code, to: { try Locale.current.languageCode.or(throw: "No languageCode") })
            state.set(blockchain.ui.device.current.local.time, to: { Date() })

            if let versionIsGreater = try? (Bundle.main.plist.version.string > state.get(blockchain.app.version)) {
                state.set(blockchain.app.did.update, to: versionIsGreater)
            }
            state.set(blockchain.app.version, to: Bundle.main.plist.version.string)

            state.set(blockchain.ui.device.settings.accessibility.large_text.is.enabled, to: UIApplication.shared.preferredContentSizeCategory > .large)
            state.set(blockchain.ui.device.settings.accessibility.content.size.category, to: UIApplication.shared.preferredContentSizeCategory.tag)
        }

        didEnterBackgroundNotification = notificationCenter.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [app] _ in app.state.set(blockchain.app.is.in.background, to: true) }

        willEnterForegroundNotification = notificationCenter.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [app] _ in app.state.set(blockchain.app.is.in.background, to: false) }

        willResignActiveNotification = notificationCenter.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [app] _ in app.post(event: blockchain.app.will.resign.active) }

        notificationCenter.publisher(for: UIApplication.userDidTakeScreenshotNotification)
            .sink { [app] _ in app.post(event: blockchain.app.did.take.screenshot) }
            .store(in: &bag)

        notificationCenter.publisher(for: UIContentSizeCategory.didChangeNotification)
            .sink { [app] event in
                guard let newValue = event.userInfo?[UIContentSizeCategory.newValueUserInfoKey] as? UIContentSizeCategory else { return }
                app.state.transaction { state in
                    state.set(blockchain.ui.device.settings.accessibility.large_text.is.enabled, to: newValue > .large)
                    state.set(blockchain.ui.device.settings.accessibility.content.size.category, to: newValue.tag)
                }
            }
            .store(in: &bag)

        app.on(blockchain.ux.type.story) { [app] event in
            app.state.set(blockchain.ux.type.analytics.current.state, to: event.reference)
        }
        .store(in: &bag)

        app.modePublisher()
            .sink { [app] mode in
                app.state.transaction { state in
                    state.set(blockchain.ux.home.id, to: mode.string)
                    state.set(blockchain.app.is.mode.pkw, to: mode == .pkw)
                    state.set(blockchain.app.is.mode.trading, to: mode == .trading)
                }
                if mode == .pkw {
                    app.post(event: blockchain.app.is.mode.pkw)
                } else {
                    app.post(event: blockchain.app.is.mode.trading)
                }
            }
            .store(in: &bag)
    }

    func stop() {

        let tasks = [
            didEnterBackgroundNotification,
            willEnterForegroundNotification
        ]

        for task in tasks {
            task?.cancel()
        }
    }
}

extension UIContentSizeCategory {

    var tag: Tag {
        switch self {
        case .extraSmall: return blockchain.ui.device.settings.accessibility.content.size.category.extra_small[]
        case .small: return blockchain.ui.device.settings.accessibility.content.size.category.small[]
        case .medium: return blockchain.ui.device.settings.accessibility.content.size.category.medium[]
        case .large: return blockchain.ui.device.settings.accessibility.content.size.category.large[]
        case .extraLarge: return blockchain.ui.device.settings.accessibility.content.size.category.extra_large[]
        case .extraExtraLarge: return blockchain.ui.device.settings.accessibility.content.size.category.extra_extra_large[]
        case .extraExtraExtraLarge: return blockchain.ui.device.settings.accessibility.content.size.category.extra_extra_extra_large[]
        case .accessibilityMedium: return blockchain.ui.device.settings.accessibility.content.size.category.accessibility.medium[]
        case .accessibilityLarge: return blockchain.ui.device.settings.accessibility.content.size.category.accessibility.large[]
        case .accessibilityExtraLarge: return blockchain.ui.device.settings.accessibility.content.size.category.accessibility.extra_large[]
        case .accessibilityExtraExtraLarge: return blockchain.ui.device.settings.accessibility.content.size.category.accessibility.extra_extra_large[]
        case .accessibilityExtraExtraExtraLarge: return blockchain.ui.device.settings.accessibility.content.size.category.accessibility.extra_extra_extra_large[]
        case _: return blockchain.ui.device.settings.accessibility.content.size.category.unspecified[]
        }
    }

}
