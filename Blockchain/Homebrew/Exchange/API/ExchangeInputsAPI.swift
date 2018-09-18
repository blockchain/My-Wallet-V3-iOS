//
//  ExchangeInputs.swift
//  Blockchain
//
//  Created by kevinwu on 8/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol ExchangeInputsAPI: class {
    
    var activeInput: String { get }
    var isUsingFiat: Bool { get set }
    var inputComponents: ExchangeInputComponents { get set }
    
    func setup(with template: ExchangeStyleTemplate, usingFiat: Bool)
    
    func primaryFiatAttributedString() -> NSAttributedString
    func primaryAssetAttributedString(symbol: String) -> NSAttributedString
    
    func maxFiatFractional() -> Int
    func maxAssetFractional() -> Int
    
    func canBackspace() -> Bool
    func canAddFiatCharacter(_ character: String) -> Bool
    func canAddAssetCharacter(_ character: String) -> Bool
    func canAddFractionalFiat() -> Bool
    func canAddFractionalAsset() -> Bool
    func canAddDelimiter() -> Bool
    
    func add(character: String)
    func add(delimiter: String)

    func clear()
    func backspace()
    func toggleInput(withOutput output: String)
}
