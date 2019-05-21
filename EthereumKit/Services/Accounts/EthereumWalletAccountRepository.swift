//
//  EthereumWalletAccountRepository.swift
//  EthereumKit
//
//  Created by kevinwu on 2/6/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift

public protocol EthereumWalletAccountRepositoryAPI {
    var keyPair: Maybe<EthereumKeyPair> { get }
    var defaultAccount: EthereumWalletAccount? { get }
    
    func initializeMetadataMaybe() -> Maybe<EthereumWalletAccount>
    func accounts() -> [EthereumWalletAccount]
}

open class EthereumWalletAccountRepository: EthereumWalletAccountRepositoryAPI, WalletAccountRepositoryAPI, KeyPairProviderAPI {
    
    public typealias KeyPair = EthereumKeyPair
    public typealias WalletAccount = EthereumWalletAccount
    public typealias Bridge =
          EthereumWalletBridgeAPI
        & MnemonicAccessAPI
        & PasswordAccessAPI
        & EthereumWalletAccountBridgeAPI

    // MARK: - Properties
    
    public var keyPair: Maybe<KeyPair> {
        return loadKeyPair()
    }

    // For ETH, there is only one account which is the default account.
    public var defaultAccount: EthereumWalletAccount?
    
    // MARK: - Private Properties
    
    private let disposeBag = DisposeBag()
    private let bridge: Bridge
    private let deriver: AnyKeyPairDeriver<EthereumKeyPair, EthereumKeyDerivationInput>
    
    // MARK: - Init

    public init<D: KeyPairDeriverAPI>(with bridge: Bridge, deriver: D) where D.Pair == EthereumKeyPair, D.Input == EthereumKeyDerivationInput {
        self.bridge = bridge
        self.deriver = AnyKeyPairDeriver<EthereumKeyPair, EthereumKeyDerivationInput>(deriver: deriver)
    }
    
    public convenience init(with bridge: Bridge) {
        self.init(with: bridge, deriver: AnyEthereumKeyPairDeriver())
    }

    // MARK: - Public methods
    
    public func initializeMetadataMaybe() -> Maybe<WalletAccount> {
        return loadDefaultAccount()
    }

    public func accounts() -> [WalletAccount] {
        guard let defaultAccount = defaultAccount else {
            return []
        }
        return [ defaultAccount ]
    }
    
    // MARK: - Private methods
    
    private func loadDefaultAccount() -> Maybe<WalletAccount> {
        return Single.zip(bridge.address, bridge.name)
            .asObservable()
            .flatMap { address, name -> Maybe<EthereumWalletAccount> in
                let account = EthereumWalletAccount(
                    index: 0,
                    publicKey: address,
                    label: name,
                    archived: false // TODO: This should be checked/enforced somehow
                )
                return Maybe.just(account)
            }
            .do(onNext: { account in
                self.defaultAccount = account
            })
            .asMaybe()
    }
    
    // MARK: - KeyPairProviderAPI
    
    public func loadKeyPair() -> Maybe<KeyPair> {
        return Maybe.zip(bridge.mnemonicPromptingIfNeeded, bridge.password)
            .flatMap { [weak self] mnemonic, password -> Maybe<KeyPair> in
                guard let self = self else { return Maybe.empty() }
                return self.deriver.derive(input: EthereumKeyDerivationInput(mnemonic: mnemonic, password: password))
            }
    }

    private func save(keyPair: KeyPair) {
        // TODO: Need to localize this
        bridge.save(keyPair: keyPair, label: "My Ethereum Wallet")
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { message in
                print(message)
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
}

extension EthereumWalletAccountRepository: WalletAccountInitializer { }
