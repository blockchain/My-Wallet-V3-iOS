//
//  WalletAccountInitializer.swift
//  PlatformKit
//
//  Created by Alex McGregor on 11/20/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// Initializer for lazily created asset accounts (XLM, ETH)
public protocol WalletAccountInitializer {
    associatedtype Account: WalletAccount
    
    // Initialize WalletAccount, get mnemonic if needed and prompt for 2nd password if needed
    func initializeMetadataMaybe() -> Maybe<Account>
}

public final class AnyWalletAccountInitializer<Account: WalletAccount>: WalletAccountInitializer {

    private let initializerClosure: () -> Maybe<Account>

    public func initializeMetadataMaybe() -> Maybe<Account> {
        return initializerClosure()
    }

    public init<I: WalletAccountInitializer>(initializer: I) where I.Account == Account {
        self.initializerClosure = initializer.initializeMetadataMaybe
    }
}
