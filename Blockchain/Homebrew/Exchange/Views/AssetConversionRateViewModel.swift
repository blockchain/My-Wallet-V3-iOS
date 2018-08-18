//
//  AssetConversionRateViewModel.swift
//  Blockchain
//
//  Created by kevinwu on 8/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class AssetConversionRateViewModel {
    fileprivate var internalBase: AssetType?
    fileprivate var internalCounter: AssetType?

    fileprivate(set) var base: AssetType? {
        get {
            return internalBase
        }
        set {
            guard newValue != internalCounter else {
                Logger.shared.error("Base and counter must be different")
                return
            }
            internalBase = newValue
        }
    }
    fileprivate(set) var counter: AssetType? {
        get {
            return internalCounter
        }
        set {
            guard newValue != internalBase else {
                Logger.shared.error("Base and counter must be different")
                return
            }
            internalCounter = newValue
        }
    }

    fileprivate(set) var fiatSymbol: String?
    fileprivate(set) var counterAssetValue: NSDecimalNumber?
    fileprivate(set) var counterFiatValue: NSDecimalNumber?
}

extension AssetConversionRateViewModel {
    func updateWithQuote(quote: Quote) {
        // implement when models are finished
    }
}
