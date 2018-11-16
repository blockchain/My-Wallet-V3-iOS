//
//  StellarKeyPair.swift
//  StellarKit
//
//  Created by Alex McGregor on 11/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

public struct StellarKeyPair: KeyPair {
    public var accountID: String
    public var secret: String
    
    public init(accountID: String, secret: String) {
        self.accountID = accountID
        self.secret = secret
    }
    
    public func save(with label: String, completion: @escaping ((String?) -> Void)) {
        // TODO: We need to remove saving a keypair from JS as well as
        // fetching metadata.
    }
}
