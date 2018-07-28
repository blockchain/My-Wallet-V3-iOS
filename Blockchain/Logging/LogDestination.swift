//
//  LogDestination.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Protocol description for a log statement destination (e.g. console, file, remote, etc.)
protocol LogDestination {

    /// Logs a statement to this destination.
    ///
    /// - Parameters:
    ///   - statement: the statement to log
    func log(statement: String)
}
