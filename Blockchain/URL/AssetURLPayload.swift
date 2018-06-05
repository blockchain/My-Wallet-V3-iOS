//
//  AssetURLPayload.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Protocol definition for a URL payload for an asset. The URL typically contains the address,
/// as well as other metadata such as an amount, message, etc. The set of supported metadata
/// can be asset dependent
@objc protocol AssetURLPayload {

    /// The asset's address (e.g. "1Amu4uPJnYbUXX2HhDFMNq7tSneDwWYDyv")
    @objc var address: String { get }

    /// The asset's scheme (e.g. "bitcoin")
    static var scheme: String { get }
}
