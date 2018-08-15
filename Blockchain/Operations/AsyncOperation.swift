//
//  AsyncOperation.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class AsyncOperation: Operation {

    // MARK: Private Properties

    /// The dispatch queue on which the execution method will be invoked.
    private let executionQueue: DispatchQueue

    /// The completion blocks are called when the operation completes.
    private var completionHandlers = [() -> Void]()

    /// Synchronizes `completionHandlers`.
    private var lock = NSLock()

    // MARK: Lifecycle

    override init() {
        self.executionQueue = DispatchQueue(
            label: "com.blockchain.AsyncOperation.executionQueue",
            qos: .background
        )
        super.init()
    }

    // MARK: Public Methods

    /// Adds a completion handler to be invoked when the operation is finished.
    /// All completion handlers will be called on the main queue. The operation
    /// will not be marked as finished until all completion handlers have been
    /// called.
    func addCompletionHandler(_ handler: @escaping () -> Void) {
        guard !isCancelled && !isFinished else { return }
        lock.lock()
        completionHandlers.append(handler)
        lock.unlock()
    }

    // MARK: Required Methods for Subclasses

    /// Begins execution of the asynchronous work. This method will *not* be
    /// called from the AsyncOperation's operation queue, but rather from a
    /// private dispatch queue.
    ///
    /// - Warning: Subclass implementations must invoke `finish` when done. If
    /// you do not invoke `finish`, the operation will remain in its executing
    /// state indefinitely.
    open func execute(finish: @escaping () -> Void) {
        assertionFailure("Subclasses must override without calling super.")
    }

    // MARK: Overrides

    override func start() {
        guard !isCancelled else { return }
        markAsExecuting()
        executionQueue.async { [weak self] in
            guard let this = self else { return }
            this.execute { [weak this] in
                DispatchQueue.main.async {
                    guard let this = this else { return }
                    guard !this.isCancelled else { return }
                    this.lock.lock()
                    let handlers = this.completionHandlers
                    this.lock.unlock()
                    handlers.forEach{ $0() }
                    this.markAsFinished()
                }
            }
        }
    }

    override var isAsynchronous: Bool {
        return true
    }

    fileprivate var _finished: Bool = false
    override var isFinished: Bool {
        get { return _finished }
        set { _finished = newValue }
    }

    fileprivate var _executing: Bool = false
    override var isExecuting: Bool {
        get { return _executing }
        set { _executing = newValue }
    }
}


fileprivate extension AsyncOperation {

    func markAsExecuting() {
        willChangeValue(for: .isExecuting)
        _executing = true
        didChangeValue(for: .isExecuting)
    }

    func markAsFinished() {
        willChangeValue(for: .isExecuting)
        willChangeValue(for: .isFinished)
        _executing = false
        _finished = true
        didChangeValue(for: .isExecuting)
        didChangeValue(for: .isFinished)
    }

    // MARK: Private

    private func willChangeValue(for key: OperationChangeKey) {
        self.willChangeValue(forKey: key.rawValue)
    }

    private func didChangeValue(for key: OperationChangeKey) {
        self.didChangeValue(forKey: key.rawValue)
    }

    private enum OperationChangeKey: String {
        case isFinished
        case isExecuting
    }
}
