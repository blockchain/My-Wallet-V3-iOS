//
//  ExchangeTradeDelegate.swift
//  Blockchain
//
//  Created by kevinwu on 8/15/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol ExchangeCreateDelegate: class {
    func onContinueButtonTapped()
    func onChangeAmountFieldText()
    func onChangeFrom(assetType: AssetType)
    func onChangeTo(assetType: AssetType)
}
