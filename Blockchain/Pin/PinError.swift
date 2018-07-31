//
//  PinError.swift
//  Blockchain
//
//  Created by Chris Arriola on 7/19/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// A generic error for the pin flow
struct PinError: Error {
    let localizedDescription: String
}
