// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension NSData {
    public var hexValue: String {
        (self as Data).hexValue
    }
}

extension Data {
    public var hexValue: String {
        map { String(format: "%02x", $0) }.reduce(into: "") { $0.append($1) }
    }

    public var bytes: [UInt8] {
        Array(self)
    }
}
