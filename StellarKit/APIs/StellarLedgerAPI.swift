//
//  StellarLedgerAPI.swift
//  StellarKit
//
//  Created by Alex McGregor on 11/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// This is not included in `PlatformKit` as no other currency has the concept of a ledger.
/// That being said, the fees for XLM supposedly don't change. We only use
/// the ledger to derive the fee.
public protocol StellarLedgerAPI {
    var current: Observable<StellarLedger> { get }
}
