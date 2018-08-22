//
//  AsyncBlockOperaiton.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class AsyncBlockOperation: AsyncOperation {
    
    typealias ExecutionBlock = (@escaping AsyncOperation.CompletionBlock) -> Void
    
    // MARK: Private Properties
    
    fileprivate let executionBlock: ExecutionBlock
    
    // MARK: Lifecycle
    
    init(executionBlock: @escaping ExecutionBlock) {
        self.executionBlock = executionBlock
    }
    
    // MARK: Overrides
    
    override func begin(done: @escaping () -> Void) {
        executionBlock(done)
    }
    
}
