//
//  TradingPair.swift
//  Blockchain
//
//  Created by kevinwu on 8/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct TradingPair {
    private var internalFrom: AssetType
    private var internalTo: AssetType

    init?(from: AssetType, to: AssetType) {
        guard from != to else {
            Logger.shared.error("From and to must be different")
            return nil
        }
        internalFrom = from
        internalTo = to
    }

    var from: AssetType {
        get {
            return internalFrom
        }
        set {
            guard newValue != internalTo else {
                Logger.shared.error("From must be different from to")
                return
            }
            internalFrom = newValue
        }
    }

    var to: AssetType {
        get {
            return internalTo
        }
        set {
            guard newValue != internalFrom else {
                Logger.shared.error("To must be different from From")
                return
            }
            internalTo = newValue
        }
    }
}
