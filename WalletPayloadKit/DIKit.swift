//
//  DIKit.swift
//  WalletPayloadKit
//
//  Created by Jack Pooley on 28/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit

extension DependencyContainer {
    
    // MARK: - WalletPayloadKit Module
     
    public static var walletPayloadKit = module {
        
        factory { WalletCryptoService() as WalletCryptoServiceAPI }
        
        factory { WalletPayloadCryptor() as WalletPayloadCryptorAPI }
        
        factory { PayloadCrypto() as PayloadCryptoAPI }
        
        factory { AESCryptor() as AESCryptorAPI }

        // MARK: Wallet Upgrade

        factory { WalletUpgradeService() as WalletUpgradeServicing }

        factory { WalletUpgradeJSService() as WalletUpgradeJSServicing }

    }
}
