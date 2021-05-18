//
//  MockContextProvider.swift
//  TestKit
//
//  Created by Paulo on 18/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import JavaScriptCore
import ToolKit

class MockContextProvider: JSContextProviderAPI {
    var underlyingContext: JSContext!

    func fetchJSContext() -> JSContext {
        underlyingContext
    }
}
