//
//  MultiAccountAssetAPI.swift
//  PlatformKit
//
//  Created by AlexM on 11/14/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// TODO: Consider renaming. HD is mapping one account to many addresses. 
public protocol MultiAccountAssetAPI {
    associatedtype Account: AssetAccount
    typealias AccountID = String
    
    /// The getter should return a `BehaviorRelay<Account?>`.
    /// The wallet metadata has a default index. This is the index that is
    /// used for returning the correct `Account` from `assetAccounts`. 
    var defaultAssetAccount: Account? { get }
    
    /// The getter should return a `BehaviorRelay<[Account]>`.
    /// Services that conform to this support currencies that permit the user
    /// to have multiple `AssetAccounts`.
    var assetAccounts: [Account] { get }
    
    /// When the account details are fetched, you should call
    /// `privateAccount.accept(account)` in order to cache the
    /// `AssetAccount`. This fetches **all** `AssetAccounts` as this is
    /// a `MultiAccountAssetAPI`. When the result is retrieved you should update
    /// the `assetAccounts`.
    func assetAccounts(fromCache: Bool) -> Maybe<[Account]>
    
    /// This will fetch the `AssetAccount` given an `accountID`.
    func accountDetails(for accountID: AccountID) -> Maybe<Account>
}
