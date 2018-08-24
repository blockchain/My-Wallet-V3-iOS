//
//  AsyncOperation.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class AsyncOperation: Operation {
    
    /// The completion blocks which will be invoked when the operation finishes.
    typealias CompletionBlock = () -> Void
    private var completionBlocks = [CompletionBlock]()
    
    /// A lock used to synchronize access to `completionBlocks`.
    /// To some this may seem like a code smell, however its purpose
    /// is to make the `completionBlocks` thread safe.
    private var lock = NSLock()
    
    /// The state of the `Operation`. We only care about setting
    /// whether or not it is executing, finished, or ready.
    private enum ExecutionState: String {
        case ready = "isReady"
        case executing = "isExecuting"
        case finished = "isFinished"
    }
    
    private var executionState: ExecutionState = .ready {
        willSet {
            willChangeValue(forKey: ExecutionState.executing.rawValue)
            willChangeValue(forKey: ExecutionState.finished.rawValue)
            willChangeValue(forKey: ExecutionState.ready.rawValue)
        }
        didSet {
            didChangeValue(forKey: ExecutionState.executing.rawValue)
            didChangeValue(forKey: ExecutionState.finished.rawValue)
            didChangeValue(forKey: ExecutionState.ready.rawValue)
        }
    }
    
    // MARK: Overrides
    
    override func start() {
        guard isCancelled == false else { return }
        executionState = .executing
        begin { [weak self] in
            DispatchQueue.main.async {
                guard let this = self else { return }
                guard this.isCancelled == false else { return }
                this.lock.lock()
                let blocks = this.completionBlocks
                this.lock.unlock()
                blocks.forEach({ $0() })
                this.executionState = .finished
            }
        }
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isFinished: Bool {
        return executionState == .finished
    }
    
    override var isExecuting: Bool {
        return executionState == .executing
    }
    
    override var isReady: Bool {
        return executionState == .ready && dependencies.filter({$0.isFinished == true}).count == dependencies.count
    }
    
    /// For custom operations, you should override this function. When your operation
    /// is complete, **you must** call `done()`. If you don't, the operation will
    /// never complete.
    func begin(done: @escaping () -> Void) {
        assertionFailure("You must override this.")
    }
    
    /// Use this for adding a completionBlock to your operation. **Do not**
    /// set `completionBlock` on `Operation` as it is not gauranteed to
    /// be called on the main thread. In fact is typically called on a
    /// secondary thread.
    func addCompletionBlock(_ block: @escaping () -> Void) {
        guard isCancelled == false && executionState != .finished else { return }
        lock.lock()
        completionBlocks.append(block)
        lock.unlock()
    }
}
