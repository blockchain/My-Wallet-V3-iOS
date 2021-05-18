//
//  DIKit.swift
//  PolkadotKit
//
//  Created by Paulo on 25/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit

extension DependencyContainer {

    public static var polkadotKit = module {

        factory(tag: CryptoCurrency.polkadot) { PolkadotAsset() as CryptoAsset }
    }
}
