//
//  StellarWalletAccountRepository.swift
//  StellarKit
//
//  Created by Alex McGregor on 11/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift

public protocol StellarWalletAccountRepositoryAPI {
    var defaultAccount: StellarWalletAccount? { get }

    func initializeMetadataMaybe() -> Maybe<StellarWalletAccount>
    func loadKeyPair() -> Maybe<StellarKeyPair>
    func loadKeyPair(with secondPassword: String?) -> Single<StellarKeyPair>
}

public class StellarWalletAccountRepository: StellarWalletAccountRepositoryAPI, WalletAccountRepositoryAPI, WalletAccountInitializer {
    public typealias Account = StellarWalletAccount
    public typealias WalletAccount = StellarWalletAccount

    private let bridge: StellarWalletBridgeAPI
    private let mnemonicAccessAPI: MnemonicAccessAPI
    private let deriver: StellarKeyPairDeriver = StellarKeyPairDeriver()
    
    init(bridge: StellarWalletBridgeAPI = resolve(),
         mnemonicAccessAPI: MnemonicAccessAPI = resolve()) {
        self.bridge = bridge
        self.mnemonicAccessAPI = mnemonicAccessAPI
    }
    
    public func initializeMetadataMaybe() -> Maybe<WalletAccount> {
        loadDefaultAccount().ifEmpty(
            switchTo: createAndSaveStellarAccount()
        )
    }
    
    /// The default `StellarWallet`, will be nil if it has not yet been initialized
    public var defaultAccount: StellarWalletAccount? {
        accounts().first
    }
    
    func accounts() -> [WalletAccount] {
        bridge.stellarWallets()
    }

    public func loadKeyPair(with secondPassword: String?) -> Single<StellarKeyPair> {
        mnemonicAccessAPI
            .mnemonic(with: secondPassword)
            .map { mnemonic in
                StellarKeyDerivationInput(mnemonic: mnemonic)
            }
            .flatMap(weak: self) { (self, input) -> Single<StellarKeyPair> in
                self.deriver.derive(input: input).single
            }
    }
    
    public func loadKeyPair() -> Maybe<StellarKeyPair> {
        mnemonicAccessAPI
            .mnemonicPromptingIfNeeded
            .flatMap { [unowned self] mnemonic -> Maybe<StellarKeyPair> in
                self.deriver.derive(input: StellarKeyDerivationInput(mnemonic: mnemonic)).maybe
            }
    }
    
    // MARK: Private
    
    private func loadDefaultAccount() -> Maybe<WalletAccount> {
        guard let defaultAccount = defaultAccount else {
            return Maybe.empty()
        }
        return Maybe.just(defaultAccount)
    }
    
    private func createAndSaveStellarAccount() -> Maybe<WalletAccount> {
        loadKeyPair()
            .flatMap(weak: self) { (self, keyPair) -> Maybe<StellarKeyPair> in
                self.save(keyPair: keyPair)
                    .andThen(Maybe.just(keyPair))
            }
            .map { keyPair -> Account in
                Account(
                    index: 0,
                    publicKey: keyPair.accountID,
                    label: CryptoCurrency.stellar.defaultWalletName,
                    archived: false
                )
            }
    }

    private func save(keyPair: StellarKeyPair) -> Completable {
        Completable.create(weak: self) { (self, observer) -> Disposable in
            self.bridge.save(
                keyPair: keyPair,
                label: CryptoCurrency.stellar.defaultWalletName,
                completion: { result in
                    switch result {
                    case .success:
                        observer(.completed)
                    case .failure:
                        observer(.error(StellarAccountError.unableToSaveNewAccount))
                    }
                }
            )
            return Disposables.create()
        }
    }
}
