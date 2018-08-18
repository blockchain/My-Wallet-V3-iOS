//
//  AssetConversionRateView.swift
//  Blockchain
//
//  Created by kevinwu on 8/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class AssetConversionRateView: UIView {
    private struct Measurements {
        static let largeLabelHeight: CGFloat = 32
        static let largeLabelOriginY: CGFloat = 16
        static let smallLabelHeight: CGFloat = 24
        static let horizontalEdgeSpacing: CGFloat = 16
    }

    private let largeLabel: UILabel
    private let smallLabel: UILabel
    private let viewModel = AssetConversionRateViewModel()

    override init(frame: CGRect) {
        self.largeLabel = UILabel(frame: CGRect(
            x: 0,
            y: Measurements.largeLabelOriginY,
            width: frame.size.width - Measurements.horizontalEdgeSpacing*2,
            height: Measurements.largeLabelHeight))
        self.smallLabel = UILabel(frame: CGRect(
            x: 0,
            y: Measurements.largeLabelOriginY + Measurements.largeLabelHeight + 8,
            width: frame.size.width - Measurements.horizontalEdgeSpacing*2,
            height: Measurements.smallLabelHeight))
        super.init(frame: frame)
        addSubview(self.largeLabel)
        addSubview(self.smallLabel)
        self.largeLabel.centerHorizontallyInSuperview()
        self.smallLabel.centerHorizontallyInSuperview()

        self.largeLabel.font = UIFont(name: Constants.FontNames.montserratSemiBold, size: Constants.FontSizes.Large)
        self.smallLabel.font = UIFont(name: Constants.FontNames.montserratLight, size: Constants.FontSizes.Small)

        self.largeLabel.textColor = UIColor.gray5
        self.smallLabel.textColor = UIColor.gray5
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        let prefix = "1 " + base.symbol + "= "
        self.largeLabel.text = prefix + counterAssetValue.stringValue + counter.symbol
        self.smallLabel.text = prefix + fiatSymbol + counterFiatValue.stringValue
    }
}
