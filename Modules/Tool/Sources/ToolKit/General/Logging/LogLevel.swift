// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Enumerates the level/severity of a log statement
public enum LogLevel {
    case debug, info, warning, error
}

extension LogLevel {

    public var emoji: String {
        switch self {
        case .debug:
            "🏗"
        case .info:
            "ℹ️"
        case .warning:
            "⚠️"
        case .error:
            "🛑"
        }
    }
}
