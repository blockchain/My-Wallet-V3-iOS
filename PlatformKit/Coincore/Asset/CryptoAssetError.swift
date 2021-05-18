//
//  CryptoAssetError.swift
//  PlatformKit
//
//  Created by Paulo on 29/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum CryptoAssetError: Error {
    case noDefaultAccount
    case addressParseFailure
}
