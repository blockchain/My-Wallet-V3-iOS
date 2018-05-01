//
//  JSContextWithDOM.swift
//  Blockchain
//
//  Created by kevinwu on 4/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import JavaScriptCore

/// JavaScriptCore is pure JavaScript - it lacks functions that are normally part of the DOM.
/// This class is intended to define these missing functions in order to make it compatible with JS libraries that use them.
class JSContextWithDOM: JSContext {

    override init() {
        super.init()

        setupConsoleFunctions()

        setupExceptionHandler()

        setupSetTimeout()
        setupClearTimeout()

        setupSetInterval()
        setupClearInterval()

        setObject(ModuleXMLHttpRequest.self, forKeyedSubscript: "XMLHttpRequest" as NSString)
    }

    required override init!(virtualMachine: JSVirtualMachine!) {
        super.init(virtualMachine: virtualMachine)
    }

    private func setupConsoleFunctions() {
        // TODO: properly define console functions
        let consoleNames = ["log",
                            "debug",
                            "info",
                            "warn",
                            "error",
                            "assert",
                            "dir",
                            "dirxml",
                            "group",
                            "groupEnd",
                            "time",
                            "timeEnd",
                            "count",
                            "trace",
                            "profile",
                            "profileEnd"]

        consoleNames.forEach { name in
            let consoleLog: @convention(block) (String) -> Void = { message in
                print("Javascript \(name): \(message)")
            }
            self.objectForKeyedSubscript("console").setObject(consoleLog, forKeyedSubscript: name as NSString)
        }
    }

    private func setupExceptionHandler() {
        self.exceptionHandler = { context, exception in
            guard let exception = exception else {
                print("Exception handler error: could not get exception")
                return
            }
            guard let message = exception.toString() else {
                print("Exception handler error: could not get message")
                return
            }
            guard let stackTrace = exception.objectForKeyedSubscript("stack").toString() else {
                print("Exception handler error: could not get stack trace")
                print("Message: \(message)")
                return
            }
            guard let lineNumber = exception.objectForKeyedSubscript("line").toString() else {
                print("Exception handler error: could not get line number")
                print("Message: \(message) \nstack:\(stackTrace)")
                return
            }
            print("\(message) \nstack: \(stackTrace)\nline number: \(lineNumber)")
        }
    }

    /// A dictionary containing the timeout/interval timers and their corresponding identifiers
    private var timers = [String: Timer]()

    private lazy var removeTimer: @convention(block) (String) -> Void = { [unowned self] identifier in
        if let timer = self.timers[identifier] {
            timer.invalidate()
            self.timers.removeValue(forKey: identifier)
        }
    }

    private func getAddTimer(repeats: Bool) -> @convention(block) (JSValue?, Double) -> String {
        let addTimer: @convention(block) (JSValue?, Double) -> String = { [unowned self] callback, timeout in
            let jsQueue = DispatchQueue(label: "jsqueue")
            let uuid = NSUUID().uuidString
            let blockOperation = BlockOperation(block: { [unowned self] in
                jsQueue.async {
                    if self.timers[uuid] != nil {
                        _ = callback?.call(withArguments: nil)
                    }
                }
            })
            let timer = Timer.scheduledTimer(timeInterval: timeout/1000,
                                             target: blockOperation,
                                             selector: #selector(BlockOperation.main),
                                             userInfo: nil,
                                             repeats: repeats)
            self.timers[uuid] = timer
            return uuid
        }
        return addTimer
    }

    private func setupSetTimeout() {
        self.setObject(getAddTimer(repeats: false), forKeyedSubscript: "setTimeout" as NSString)
    }

    private func setupClearTimeout() {
        self.setObject(removeTimer, forKeyedSubscript: "clearTimeout" as NSString)
    }

    private func setupSetInterval() {
        self.setObject(getAddTimer(repeats: true), forKeyedSubscript: "setInterval" as NSString)
    }

    private func setupClearInterval() {
        self.setObject(removeTimer, forKeyedSubscript: "clearInterval" as NSString)
    }
}
