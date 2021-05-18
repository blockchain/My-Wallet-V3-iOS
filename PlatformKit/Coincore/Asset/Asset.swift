//
//  Asset.swift
//  PlatformKit
//
//  Created by Paulo on 29/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import RxSwift
import ToolKit

public enum AssetFilter {
    case all
    case nonCustodial
    case custodial
    case interest
}

public enum AssetAction: Equatable {
    case viewActivity
    case deposit
    case sell
    case send
    case receive
    case swap
    case withdraw
}

public typealias AvailableActions = Set<AssetAction>

public protocol Asset {

    func accountGroup(filter: AssetFilter) -> Single<AccountGroup>
    
    func transactionTargets(account: SingleAccount) -> Single<[SingleAccount]>

    /// Validates the given address
    /// - Parameter address: A `String` value of the address to be parse
    func parse(address: String) -> Single<ReceiveAddress?>
}

public protocol CryptoAsset: Asset {
    var asset: CryptoCurrency { get }
    var defaultAccount: Single<SingleAccount> { get }
}

public enum CryptoAssetError: Error {
    case noDefaultAccount
    case addressParseFailure
}

extension CryptoAsset {
    
    public func transactionTargets(account: SingleAccount) -> Single<[SingleAccount]> {
        guard let crypto = account as? CryptoAccount else {
            fatalError("Expected a CryptoAccount: \(account)")
        }
        precondition(crypto.asset == asset)
        // TODO: Fetch exchange accounts
        switch crypto {
        case is CryptoTradingAccount:
            return accountGroup(filter: .nonCustodial)
                .map(\.accounts)
        case is CryptoNonCustodialAccount:
            return accountGroup(filter: .all)
                .map(\.accounts)
                .flatMapFilter(excluding: crypto.id)
        default:
            unimplemented()
        }
    }
}
