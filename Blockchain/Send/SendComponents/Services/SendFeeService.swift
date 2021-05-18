//
//  SendFeeService.swift
//  Blockchain
//
//  Created by Daniel Huri on 14/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import DIKit
import EthereumKit
import Foundation
import PlatformKit
import RxRelay
import RxSwift

protocol SendFeeServicing: class {
    
    /// An observable that streams the fee
    var fee: Observable<CryptoValue> { get }

    /// A trigger to (re-)fetch the fee. Handy for any refresh scenario
    var triggerRelay: PublishRelay<Void> { get }
}

final class SendFeeService: SendFeeServicing {
    
    // MARK: - Exposed Properties

    // TODO: Failure retry logic

    var fee: Observable<CryptoValue> {
        let fee: Observable<CryptoValue>
        switch asset {
        case .ethereum:
            fee = etherFee
        case .aave,
             .algorand,
             .bitcoin,
             .bitcoinCash,
             .pax,
             .polkadot,
             .stellar,
             .tether,
             .wDGLD,
             .yearnFinance:
            fatalError("\(#function) does not support \(asset.name)")
        }
        return Observable
            .combineLatest(fee, triggerRelay)
            .map { $0.0 }
    }
    
    let triggerRelay = PublishRelay<Void>()
    
    // MARK: - Private Properties
    
    private var etherFee: Observable<CryptoValue> {
        ethereumService.fees
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map { fee -> CryptoValue in
                let gasPrice = BigUInt(fee.regular.amount)
                let gasLimit = BigUInt(fee.gasLimit)
                let cost = gasPrice * gasLimit
                if let value = CryptoValue.ether(minor: "\(cost)") {
                    return value
                } else {
                    throw MoneyValuePairCalculationState.CalculationError.valueCouldNotBeCalculated
                }
            }
            .asObservable()
    }
    
    // MARK: - Injected
    
    private let asset: CryptoCurrency
    private let ethereumService: CryptoFeeService<EthereumTransactionFee>
    
    // MARK: - Setup
    
    init(asset: CryptoCurrency,
         ethereumService: CryptoFeeService<EthereumTransactionFee> = resolve()) {
        self.asset = asset
        self.ethereumService = ethereumService
    }    
}
