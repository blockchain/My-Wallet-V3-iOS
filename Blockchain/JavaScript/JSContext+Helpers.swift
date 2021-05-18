//
//  JSContext+Helpers.swift
//  Blockchain
//
//  Created by Chris Arriola on 9/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import JavaScriptCore
import ToolKit

extension JSContext {
    /// A helper method to enforce the execution of JSContext to be on a single thread, specifically on the MainThread
    @objc func evaluateScriptCheckIsOnMainQueue(_ script: String!) -> JSValue! {
        #if INTERNAL_BUILD
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        #else
        ProbabilisticRunner.run(for: .onePercent) {
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        }
        #endif
        return self.evaluateScript(script)
    }
}
