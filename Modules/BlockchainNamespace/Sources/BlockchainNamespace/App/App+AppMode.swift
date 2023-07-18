// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public enum AppMode: String, Decodable, Equatable {
    /// aka `DeFi`
    case pkw = "PKW"
    case trading = "TRADING"
}

extension AppProtocol {
    public func modePublisher() -> AnyPublisher<AppMode, Never> {
        publisher(for: blockchain.app.mode, as: AppMode.self)
            .replaceError(with: .trading)
    }

    public var currentMode: AppMode {
        state.get(blockchain.app.mode, as: AppMode.self, or: .trading)
    }

    public func mode() async -> AppMode {
        await get(blockchain.app.mode, as: AppMode.self, or: .trading)
    }
}
