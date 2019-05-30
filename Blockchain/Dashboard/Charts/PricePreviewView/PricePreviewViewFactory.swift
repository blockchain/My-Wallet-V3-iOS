//
//  PricePreviewViewFactory.swift
//  Blockchain
//
//  Created by Maurice A. on 10/23/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

final class PricePreviewViewFactory {

    typealias ButtonTapHandler = () -> Void

    class func create(for assetType: AssetType, price: String? = nil, buttonTapped: @escaping ButtonTapHandler) -> PricePreviewView {
        let thePricePreviewView = PricePreviewView.fromNib() as PricePreviewView
        thePricePreviewView.price = price ?? "0"
        thePricePreviewView.currencyTitle = String(format: "%@ Price", assetType.description)
        thePricePreviewView.buttonImage = assetType.filledImageSmall
        thePricePreviewView.seeChartsButtonHandler = buttonTapped
        return thePricePreviewView
    }
}
