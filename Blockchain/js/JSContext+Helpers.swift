//
//  JSContext+Helpers.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import JavaScriptCore

extension JSContext {
    /// Invokes the native block `functionBlock` for the provided JS function name `functionName`.
    /// Once the function is invoked, the native block is cleared from this JSContext.
    ///
    /// - Parameters:
    ///   - functionBlock: the native block
    ///   - key: the function name
    @objc func invokeOnce(functionBlock: @escaping () -> Void, forJsFunctionName functionName: (NSCopying & NSObjectProtocol)) {
        let theBlock: @convention(block) () -> Void = { [weak self] in
            functionBlock()
            self?.setObject(nil, forKeyedSubscript: functionName)
        }
        self.setObject(theBlock, forKeyedSubscript: functionName)
    }
    @objc func invokeOnce(stringFunctionBlock: @escaping (String) -> Void, forJsFunctionName functionName: (NSCopying & NSObjectProtocol)) {
        let theBlock: @convention(block) (String) -> Void = { [weak self] string in
            stringFunctionBlock(string)
            self?.setObject(nil, forKeyedSubscript: functionName)
        }
        self.setObject(theBlock, forKeyedSubscript: functionName)
    }
}
