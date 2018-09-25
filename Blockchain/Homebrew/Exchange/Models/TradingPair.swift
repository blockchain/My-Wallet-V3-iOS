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
        // TODO: This used to return early with `nil`.
        // Some have already executed trades though when
        // there was a server side bug that allowed for the
        // two asset types to be the same. So, when those of
        // us who have that in our trade history GET trades
        // we hit an assertion error. 
        if from == to {
            Logger.shared.error("From and to must be different")
        }
        internalFrom = from
        internalTo = to
    }
    
    init?(string: String) {
        var components: [String] = []
        for value in ["-", "_"] {
            if string.contains(value) {
                components = string.components(separatedBy: value)
                break
            }
        }
        
        guard let from = components.first else { return nil }
        guard let to = components.last else { return nil }
        guard let toAsset = AssetType(stringValue: to) else { return nil }
        guard let fromAsset = AssetType(stringValue: from) else { return nil }
        
        self.init(from: fromAsset, to: toAsset)
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
    
    var stringRepresentation: String {
        return internalFrom.symbol + "-" + internalTo.symbol
    }
}

extension TradingPair: Equatable {
    static func ==(lhs: TradingPair, rhs: TradingPair) -> Bool {
        return lhs.internalFrom == rhs.internalFrom &&
            lhs.internalTo == rhs.internalTo
    }
}

extension TradingPair: Hashable {
    var hashValue: Int {
        return internalTo.hashValue ^
        internalFrom.hashValue
    }
}
