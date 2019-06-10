//
//  EIP67URI.swift
//  EthereumKit
//
//  Created by Jack on 07/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

public protocol EIP67URI: AssetURLPayload {
    init?(address: String, amount: String?, gas: String?)
    
    init?(url: URL)
    init?(rawValue: String)
}
