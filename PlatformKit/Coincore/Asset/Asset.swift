//
//  Asset.swift
//  PlatformKit
//
//  Created by Paulo on 29/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import RxSwift
import ToolKit

public protocol Asset {

    /// Gives a chance for the `Asset` to initialize itself.
    func initialize() -> Completable

    func accountGroup(filter: AssetFilter) -> Single<AccountGroup>
    
    func transactionTargets(account: SingleAccount) -> Single<[SingleAccount]>

    /// Validates the given address
    /// - Parameter address: A `String` value of the address to be parse
    func parse(address: String) -> Single<ReceiveAddress?>
}
