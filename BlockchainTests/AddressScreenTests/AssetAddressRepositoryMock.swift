//
//  AssetAddressRepositoryMock.swift
//  BlockchainTests
//
//  Created by Daniel Huri on 02/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

@testable import Blockchain
import BitcoinCashKit
import BitcoinKit
import ERC20Kit
import EthereumKit
import PlatformKit
import RxSwift
import StellarKit

class AssetAddressRepositoryMock: AssetAddressFetching {
    
    let isReusable: Bool
    var alreadyUsedAddress: String?
    var addresses: [String]
    
    init(isReusable: Bool, addresses: [String], alreadyUsedAddress: String? = nil) {
        self.isReusable = isReusable
        self.addresses = addresses
        self.alreadyUsedAddress = alreadyUsedAddress
    }
    
    /// Checks usability of an asset address
    func checkUsability(of address: String, asset: CryptoCurrency) -> Single<AddressUsageStatus> {
        if isReusable {
            return .just(.unused(address: address))
        } else if address == alreadyUsedAddress {
            return .just(.used(address: address))
        } else {
            return .just(.unused(address: address))
        }
    }
    
    /// Return the candidate addresses by type and asset
    func addresses(by type: AssetAddressType, asset: CryptoCurrency) -> [AssetAddress] {
        var result: [AssetAddress] = []
        for address in addresses {
            switch asset {
            case .aave:
                result += [AnyERC20AssetAddress<AaveToken>(publicKey: address)]
            case .algorand, .polkadot:
                break
            case .bitcoin:
                result += [BitcoinAssetAddress(publicKey: address)]
            case .bitcoinCash:
                result += [BitcoinCashAssetAddress(publicKey: address)]
            case .ethereum:
                result += [EthereumAddress(stringLiteral: address)]
            case .pax:
                result += [AnyERC20AssetAddress<PaxToken>(publicKey: address)]
            case .stellar:
                result += [StellarAssetAddress(publicKey: address)]
            case .tether:
                result += [AnyERC20AssetAddress<TetherToken>(publicKey: address)]
            case .wDGLD:
                result += [AnyERC20AssetAddress<WDGLDToken>(publicKey: address)]
            case .yearnFinance:
                result += [AnyERC20AssetAddress<YearnFinanceToken>(publicKey: address)]
            }
        }
        return result
    }
    
    /// Removes a given asset address according to type
    func remove(address: String, for assetType: CryptoCurrency, addressType: AssetAddressType) {
        guard let index = addresses.firstIndex(where: { $0 == address }) else {
            return
        }
        addresses.remove(at: index)
    }
}
