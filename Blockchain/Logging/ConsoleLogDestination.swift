//
//  ConsoleLogDestination.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class ConsoleLogDestination: LogDestination {
    func log(statement: String) {
        print(statement)
    }
}
