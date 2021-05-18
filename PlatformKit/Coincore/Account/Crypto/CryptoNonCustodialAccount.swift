//
//  CryptoNonCustodialAccount.swift
//  PlatformKit
//
//  Created by Paulo on 03/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol CryptoNonCustodialAccount: CryptoAccount, NonCustodialAccount {
    func updateLabel(_ newLabel: String) -> Completable
}

extension CryptoNonCustodialAccount {

    // TODO: Swap: Use new PayloadManager to check if it is double encrypted.
    public var requireSecondPassword: Single<Bool> {
        .just(false)
    }

    public var accountType: SingleAccountType {
        .nonCustodial
    }
    
    public var isFunded: Single<Bool> {
        balance
            .map { $0.isPositive }
    }

    public func updateLabel(_ newLabel: String) -> Completable {
        .error(PlatformKitError.illegalStateException(message: "Cannot update account label for \(asset.name) accounts"))
    }
}
