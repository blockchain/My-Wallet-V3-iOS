//
//  BitcoinCashAddressValidatorAPI.swift
//  BitcoinCashKit
//
//  Created by Alex McGregor on 3/16/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol BitcoinCashAddressValidatorAPI {
    func validate(address: String) -> Completable
}
