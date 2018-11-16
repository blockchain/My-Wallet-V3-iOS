//
//  HistoricalTransactionStreamingAPI.swift
//  PlatformKit
//
//  Created by Alex McGregor on 11/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// `HistoricalTransactionStreamingAPI` is used for streaming transactions that the user,
/// has submitted. To use this you'll need to leverage `ReplaySubject<[HistoricalTransaction]>`.
/// Create an "unbounded" version of this in order to cache the transactions received.
/// - **Note: You must call `end()` and `clear()` when the user signs out.**
public protocol HistoricalTransactionStreamingAPI {
    associatedtype Model: HistoricalTransaction
    
    var transactions: Observable<[Model]> { get }
    
    func isStreaming() -> Bool
    func end()
    func clear()
}
