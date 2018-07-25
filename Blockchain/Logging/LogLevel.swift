//
//  LogLevel.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Enumerates the level/severity of a log statement
enum LogLevel {
    case debug, info, warning, error
}

extension LogLevel {

    var emoji: String {
        switch self {
        case .debug: return "🏗"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "🛑"
        }
    }
}
