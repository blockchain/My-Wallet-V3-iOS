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

    var didEnterBackgroundNotification, willEnterForegroundNotification: AnyCancellable?
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
        }

        didEnterBackgroundNotification = notificationCenter.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [app] _ in app.state.set(blockchain.app.is.in.background, to: true) }

        willEnterForegroundNotification = notificationCenter.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [app] _ in app.state.set(blockchain.app.is.in.background, to: false) }

        app.modePublisher()
            .sink { [app] mode in
                app.state.transaction { state in
                    state.set(blockchain.ux.home.id, to: mode.string)
                    switch mode {
                    case .universal:
                        state.clear(blockchain.app.is.mode.pkw)
                        state.clear(blockchain.app.is.mode.trading)
                    default:
                        state.set(blockchain.app.is.mode.pkw, to: mode == .pkw)
                        state.set(blockchain.app.is.mode.trading, to: mode == .trading)
                    }
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
