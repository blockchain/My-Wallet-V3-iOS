// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public enum AppMode: String, Decodable, Equatable {
    /// aka `DeFi`
    case pkw = "PKW"
    case trading = "TRADING"
    case universal = "UNIVERSAL"
}

extension AppProtocol {

    public func modePublisher() -> AnyPublisher<AppMode, Never> {
        publisher(for: blockchain.app.mode, as: AppMode.self)
            .replaceError(with: .trading)
    }

    public var currentMode: AppMode {
        stateCurrentMode ?? .trading
    }

    private var stateCurrentMode: AppMode? {
        try? state.get(blockchain.app.mode, as: AppMode.self)
    }

    public func mode() async -> AppMode {
        do {
            return try await get(blockchain.app.mode, as: AppMode.self)
        } catch {
            return .trading
        }
    }
}
