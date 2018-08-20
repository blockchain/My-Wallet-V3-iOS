//
//  Promise.swift
//  Blockchain
//
//  Created by Justin on 8/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public class CompletableFuture<PromisedType> {
    
    var doneBlocks: [(_:PromisedType) -> Void]?
    var promisedObj: PromisedType?
    let completionQueue: DispatchQueue
    let promiseSequence = DispatchQueue(label: "com.blockchain.promiseCompletion")
    
    public var canceled: Bool {
        //  get {
        var val = false
        promiseSequence.sync {
            guard promisedObj == nil else {
                return
            }
            val = doneBlocks == nil
        }
        return val
        //   }
    }
    
    public init(completionQueue: DispatchQueue = .global() ) {
        doneBlocks = []
        self.completionQueue = completionQueue
    }
    
    public func fetchNow() -> PromisedType? {
        var result = nil as PromisedType?
        promiseSequence.sync {
            result = self.promisedObj
        }
        return result
    }
    
    public func complete(value: PromisedType) {
        promiseSequence.async {
            guard let completionBlocks = self.doneBlocks,
                self.promisedObj == nil  else {
                    // already completed or canceled
                    return
            }
            self.promisedObj = value
            completionBlocks.forEach({ (handler: @escaping (PromisedType) -> Void) in
                self.completionQueue.async {
                    handler(value)
                }
            })
            self.doneBlocks = nil
        }
    }
    
    public func cancel() {
        promiseSequence.async {
            guard self.doneBlocks != nil else {
                return
            }
            self.doneBlocks = nil
        }
    }
    
    public func finally() {
        // TODO: Implement
        //regardless of errors, do this when everything completes
    }
    
    public func failure() -> NSError {
        promiseSequence.sync {
            guard self.doneBlocks != nil else {
                self.doneBlocks = nil
                return
            }
        }
        return NSError(domain: "<self>", code: 1, userInfo: nil)
    }
    
    @discardableResult
    public func then(handler: (@escaping (_ :PromisedType) -> Void) ) -> CompletableFuture {
        promiseSequence.async {
            if let value = self.promisedObj {
                // already completed
                self.completionQueue.async {
                    handler(value)
                }
            } else {
                // enqueue
                if self.doneBlocks != nil {
                    self.doneBlocks!.append(handler)
                }
            }
        }
        return self
    }
}
