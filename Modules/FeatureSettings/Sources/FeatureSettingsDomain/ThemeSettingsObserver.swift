// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import UIKit

public final class ThemeSettingsObserver: BlockchainNamespace.Client.Observer {

    private let app: AppProtocol
    private let window: UIWindow
    private var bag: Set<AnyCancellable> = []

    public init(
        app: AppProtocol,
        window: UIWindow
    ) {
        self.app = app
        self.window = window
    }

    public func start() {
        app.publisher(for: blockchain.app.settings.theme.mode, as: DarkModeSetting.self)
            .map(\.value)
            .receive(on: DispatchQueue.main)
            .sink { [window] setting in
                let setting = setting ?? DarkModeSetting.automatic
                window.overrideUserInterfaceStyle = setting.userInterfaceStyle
            }
            .store(in: &bag)
    }

    public func stop() {
        bag = []
    }
}

extension DarkModeSetting {
    var userInterfaceStyle: UIUserInterfaceStyle {
            switch self {
            case .automatic:
                return .unspecified
            case .light:
                return .light
            case .dark:
                return .dark
            }
        }
}
