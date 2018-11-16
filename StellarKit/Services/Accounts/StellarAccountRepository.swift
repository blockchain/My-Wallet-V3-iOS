//
//  StellarAccountRepository.swift
//  StellarKit
//
//  Created by Alex McGregor on 11/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit

open class StellarAccountRepository: WalletAccountRepositoryAPI {
    
    /// The default `WalletAccount`, will be nil if it has not yet been initialized
    open var defaultAccount: WalletAccount? {
        return accounts().first
    }
    
    open func accounts() -> [WalletAccount] {
        return []
    }
}
