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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
