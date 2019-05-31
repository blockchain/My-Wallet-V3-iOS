//
//  SendMoniesInternalError.swift
//  Blockchain
//
//  Created by AlexM on 5/30/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import ERC20Kit

enum SendMoniesInternalError: Error {
    /// `insufficientFeeCoverage` is also
    /// insufficient ethereum balance.
    case insufficientFeeCoverage
    case insufficientTokenBalance
    case invalidDestinationAddress
    case `default`
    
    init(erc20error: ERC20ServiceError) {
        switch erc20error {
        case .insufficientEthereumBalance:
            self = .insufficientFeeCoverage
        case .insufficientTokenBalance:
            self = .insufficientTokenBalance
        case .invalidEthereumAddress:
            self = .invalidDestinationAddress
        case .invalidCyptoValue:
            self = .default
        }
    }
}

extension SendMoniesInternalError {
    var title: String {
        switch self {
        case .insufficientFeeCoverage:
            return LocalizationConstants.SendAsset.notEnoughEth
        case .insufficientTokenBalance:
            return String(format: "\(LocalizationConstants.SendAsset.notEnough) %@", AssetType.pax.description)
        case .invalidDestinationAddress:
            return LocalizationConstants.SendAsset.invalidDestinationAddress
        case .default:
            return LocalizationConstants.Errors.error
        }
    }
    
    var description: String? {
        switch self {
        case .insufficientFeeCoverage:
            return String(format: "\(LocalizationConstants.SendAsset.notEnoughEthDescription), %@.", AssetType.pax.description)
        case .insufficientTokenBalance:
            return String(format: "\(LocalizationConstants.SendAsset.notEnough) %@", AssetType.pax.description)
        case .invalidDestinationAddress:
            return LocalizationConstants.SendAsset.invalidDestinationDescription
        case .default:
            return LocalizationConstants.Errors.error
        }
    }
}
