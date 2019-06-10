//
//  AssetURLPayload.swift
//  PlatformKit
//
//  Created by Chris Arriola on 6/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Protocol definition for a URL payload for an asset. The URL typically contains the address,
/// as well as other metadata such as an amount, message, etc. The set of supported metadata
/// can be asset dependent
@objc public protocol AssetURLPayload {

    /// The asset's address (e.g. "1Amu4uPJnYbUXX2HhDFMNq7tSneDwWYDyv")
    @objc var address: String { get }

    @objc var amount: String? { get }

    /// Same as scheme - mostly here for obj-c compatibility reasons
    @objc var schemeCompat: String { get }

    /// Converts this URL to an absolute string (e.g. "bitcoin:1Amu4uPJnYbUXX2HhDFMNq7tSneDwWYDyv")
    @objc var absoluteString: String { get }

    /// The asset's scheme (e.g. "bitcoin")
    static var scheme: String { get }
}
