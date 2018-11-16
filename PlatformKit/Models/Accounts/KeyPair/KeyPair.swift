//
//  KeyPair.swift
//  PlatformKit
//
//  Created by Alex McGregor on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol KeyPair {
    var accountID: String { get }
    var secret: String { get }
    
    func save(with label: String, completion: @escaping ((String?) -> Void))
}
