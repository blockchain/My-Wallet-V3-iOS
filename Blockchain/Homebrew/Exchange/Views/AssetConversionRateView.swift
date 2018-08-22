//
//  AssetConversionRateView.swift
//  Blockchain
//
//  Created by kevinwu on 8/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class AssetConversionRateView: UIView {
    @IBOutlet var largeLabel: UILabel!
    @IBOutlet var smallLabel: UILabel!

    private let viewModel = AssetConversionRateViewModel()

    override func layoutSubviews() {
        super.layoutSubviews()
        largeLabel.textColor = UIColor.gray5
        smallLabel.textColor = UIColor.gray5
    }
}

extension AssetConversionRateView {
    func updateViewModelWithQuote(quote: Quote) {
        viewModel.updateWithQuote(quote: quote)
        updateUI()
    }

    func updateUI() {
        guard let base = viewModel.base,
            let counter = viewModel.counter,
            let counterAssetValue = viewModel.counterAssetValue,
            let counterFiatValue = viewModel.counterFiatValue,
            let fiatSymbol = viewModel.fiatSymbol else {
            Logger.shared.error("Missing view model information. Cannot update UI")
            return
        }
        let prefix = "1 " + base.symbol + " = "
        largeLabel.text = prefix + counterAssetValue.stringValue + " " + counter.symbol
        smallLabel.text = prefix + fiatSymbol + counterFiatValue.stringValue
    }
}
