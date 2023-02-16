// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol Preferences {
    func object(forKey defaultName: String) -> Any?
    func set(_ value: Any?, forKey defaultName: String)
}

extension Preferences {

    public func transaction(_ key: String, _ yield: (inout Any?) throws -> Void) rethrows {
        var object = object(forKey: key)
        try yield(&object)
        set(object, forKey: key)
    }
}

extension UserDefaults: Preferences {}
