//
//  PinStoreError.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// An error encountered while interacting with the /pin-store Blockchain API endpoint
struct PinStoreError: Error {
    let errorMessage: String?
}
