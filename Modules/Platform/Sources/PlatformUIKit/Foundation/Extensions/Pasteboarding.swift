// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol Pasteboarding: AnyObject {
    func set(string: String)
}

extension UIPasteboard: Pasteboarding {

    public func set(string: String) {
        self.string = string
    }
}
