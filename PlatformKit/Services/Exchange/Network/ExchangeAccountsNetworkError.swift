//
//  ExchangeAccountsNetworkError.swift
//  PlatformKit
//
//  Created by Alex McGregor on 3/10/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

public enum ExchangeAccountsNetworkError: Error {
    /// An error thrown when the user doesn't have an Exchange account to fetch his Exchange address from
    case missingAccount
}
