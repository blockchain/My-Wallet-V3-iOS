//
//  EthereumKeyPairDeriver.swift
//  EthereumKit
//
//  Created by Jack on 13/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import web3swift
import RxSwift

extension AnyEthereumKeyPairDeriver {
    public convenience init() {
        self.init(with: EthereumKeyPairDeriver.shared)
    }
}

public class EthereumKeyPairDeriver: EthereumKeyPairDeriverAPI {
    static let shared = EthereumKeyPairDeriver()
    
    public func derive(input: EthereumKeyDerivationInput) -> Maybe<EthereumKeyPair> {
        let mnemonic = input.mnemonic
        let password = input.password
        guard
            let mnemonics = try? Mnemonics(mnemonic),
            let keystore = try? BIP32Keystore(
                mnemonics: mnemonics,
                password: password,
                prefixPath: HDNode.defaultPathMetamaskPrefix
            )
        else {
            return Maybe.empty()
        }
        let address = keystore.addresses[0]
        guard
            let privateKey = try? keystore.UNSAFE_getPrivateKeyData(password: password, account: address),
            let publicKey = try? Web3Utils.privateToPublic(privateKey, compressed: true),
            let accountAddress = try? Web3Utils.publicToAddressString(publicKey)
        else {
            return Maybe.empty()
        }
        return Maybe.just(
            EthereumKeyPair(
                accountID: accountAddress,
                privateKey: EthereumPrivateKey(
                    mnemonic: mnemonic,
                    password: password,
                    data: privateKey
                )
            )
        )
    }
}
