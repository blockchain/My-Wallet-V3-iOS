//
//  EthereumAccountValidator.swift
//  EthereumKit
//
//  Created by AlexM on 5/24/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import RxSwift
import web3swift

public struct EthereumAccountValidator: AccountValidationAPI {
    public static func validate(accountID: AccountID) -> Single<Bool> {
        return Single.just(web3swift.Address(accountID).isValid)
    }
}
