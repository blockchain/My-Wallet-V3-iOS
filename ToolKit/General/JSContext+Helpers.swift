//
//  JSContext+Helpers.swift
//  ToolKit
//
//  Created by Paulo on 19/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import JavaScriptCore

extension JSContext {
    /// Invokes the native block `functionBlock` for the provided JS function name `functionName`.
    /// Once the function is invoked, the native block is cleared from this JSContext.
    ///
    /// - Parameters:
    ///   - functionBlock: the native block
    ///   - functionName: the function name
    @objc public func invokeOnce(functionBlock: @escaping () -> Void, forJsFunctionName functionName: (NSCopying & NSObjectProtocol)) {
        let theBlock: @convention(block) () -> Void = { [weak self] in
            functionBlock()
            self?.setObject(nil, forKeyedSubscript: functionName)
        }
        self.setObject(theBlock, forKeyedSubscript: functionName)
    }

    @objc public func invokeOnce(stringFunctionBlock: @escaping (String) -> Void, forJsFunctionName functionName: (NSCopying & NSObjectProtocol)) {
        let theBlock: @convention(block) (String) -> Void = { [weak self] string in
            stringFunctionBlock(string)
            self?.setObject(nil, forKeyedSubscript: functionName)
        }
        self.setObject(theBlock, forKeyedSubscript: functionName)
    }

    @objc public func invokeOnce(valueFunctionBlock: @escaping (JSValue) -> Void, forJsFunctionName functionName: (NSCopying & NSObjectProtocol)) {
        let theBlock: @convention(block) (JSValue) -> Void = { [weak self] jsValue in
            valueFunctionBlock(jsValue)
            self?.setObject(nil, forKeyedSubscript: functionName)
        }
        self.setObject(theBlock, forKeyedSubscript: functionName)
    }

    @objc public func setJsFunction(named functionName: (NSCopying & NSObjectProtocol), valueFunctionBlock: @escaping (JSValue) -> Void) {
        let theBlock: @convention(block) (JSValue) -> Void = { jsValue in
            valueFunctionBlock(jsValue)
        }
        self.setObject(theBlock, forKeyedSubscript: functionName)
    }

    @objc public func setJsFunction(named functionName: (NSCopying & NSObjectProtocol), functionBlock: @escaping () -> Void) {
        let theBlock: @convention(block) () -> Void = {
            functionBlock()
        }
        self.setObject(theBlock, forKeyedSubscript: functionName)
    }
}
