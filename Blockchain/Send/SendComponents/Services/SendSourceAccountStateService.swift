//
//  SendSourceAccountStateServicing.swift
//  Blockchain
//
//  Created by Daniel Huri on 11/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import EthereumKit
import Foundation
import PlatformKit
import RxRelay
import RxSwift

/// A protocol that should check if the source account is valid for making a transaction
protocol SendSourceAccountStateServicing: class {
    
    /// Streams the source account state
    var state: Observable<SendSourceAccountState> { get }
    
    /// Recalculates the state
    func recalculateState()
}

/// Any constraint that applies to the source account should go here
final class SendSourceAccountStateService: SendSourceAccountStateServicing {
    
    // MARK: - Properties
    
    /// Streams the source account state
    var state: Observable<SendSourceAccountState> {
        stateRelay
            .asObservable()
            .distinctUntilChanged()
    }
    
    private let stateRelay = BehaviorRelay<SendSourceAccountState>(value: .available)
    private let disposeBag = DisposeBag()
    
    // MARK: Injected
    
    private let asset: CryptoCurrency
    private let ethereumService: EthereumWalletServiceAPI
    
    // MARK: - Setup
    
    init(asset: CryptoCurrency, ethereumService: EthereumWalletServiceAPI = resolve()) {
        self.asset = asset
        self.ethereumService = ethereumService
    }
    
    /// Recalculates the state of the source account
    func recalculateState() {
        switch asset {
        case .ethereum:
            recalculateStateForEtherBasedAssets()
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
            fatalError("\(#function) is not implemented for \(asset)")
        }
    }
    
    private func recalculateStateForEtherBasedAssets() {
        guard !stateRelay.value.isCalculating else { return }
        stateRelay.accept(.calculating)
        ethereumService.handlePendingTransaction
            .subscribe(onSuccess: { [weak self] _ in
                self?.stateRelay.accept(.available)
            }, onError: { [weak self] _ in
                self?.stateRelay.accept(.pendingTransactionCompletion)
            })
            .disposed(by: disposeBag)
    }
}
