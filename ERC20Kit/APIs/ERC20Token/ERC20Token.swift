//
//  ERC20Token.swift
//  ERC20Kit
//
//  Created by Jack on 15/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
import web3swift
import PlatformKit
import EthereumKit

public protocol ERC20Token {
    static var assetType: CryptoCurrency { get }
    static var name: String { get }
    static var metadataKey: String { get }
    static var contractAddress: EthereumContractAddress { get }
    static var smallestSpendableValue: ERC20TokenValue<Self> { get }
    
    static func cryptoValueFrom(majorValue: String) -> ERC20TokenValue<Self>?
    static func cryptoValueFrom(majorValue: Decimal) -> ERC20TokenValue<Self>?
    
    static func cryptoValueFrom(minorValue: String) -> ERC20TokenValue<Self>?
    static func cryptoValueFrom(minorValue: BigInt) -> ERC20TokenValue<Self>?
}

extension ERC20Token {
    public static var name: String {
        return assetType.rawValue
    }
    
    public static var metadataKey: String {
        return assetType.rawValue.lowercased()
    }
}

@objc public class ERC20TokenObjcBridge: NSObject {
    @objc public class func paxContractAddress() -> String { return PaxToken.contractAddress.rawValue }
}
