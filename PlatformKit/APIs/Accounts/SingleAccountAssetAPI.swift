//
//  SingleAccountAssetAPI.swift
//  PlatformKit
//
//  Created by AlexM on 11/14/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// TODO: Consider renaming. Non-HD mapping == mapping one account to one address. We should
/// consider implying some sort of hierarchy.
/// **Note:** Some currencies like XLM may support multiple accounts, however in our wallet
/// we may be only supporting one account. If that is the case, the service should confirm to this
/// API and **not** `MultiAccountAssetAPI`. 
public protocol SingleAccountAssetAPI {
    associatedtype Account: AssetAccount
    typealias AccountID = String
    
    /// The getter should return a `BehaviorRelay<Account?>`.
    var defaultAssetAccount: Account? { get }
    
    /// When the account details are fetched, you should call
    /// `privateAccount.accept(account)` in order to cache the
    /// `AssetAccount`.
    func currentAssetAccount(fromCache: Bool) -> Maybe<Account>
    
    /// This will fetch the `AssetAccount` given an `accountID`.
    func accountDetails(for accountID: AccountID) -> Maybe<Account>
}
