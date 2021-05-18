//
//  JSContextProviderAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 06/12/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import JavaScriptCore

public protocol JSContextProviderAPI: AnyObject {
    var jsContext: JSContext { get }
    func fetchJSContext() -> JSContext
}

extension JSContextProviderAPI {
    public var jsContext: JSContext {
        fetchJSContext()
    }
}
