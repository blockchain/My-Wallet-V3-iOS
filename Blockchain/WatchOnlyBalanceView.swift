//
//  WatchOnlyBalanceView.swift
//  Blockchain
//
//  Created by kevinwu on 7/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc class WatchOnlyBalanceView: UIView {

    private let assetLabel: UILabel
    private let balanceLabel: BCInsetLabel

    override init(frame: CGRect) {
        self.assetLabel = UILabel(frame: CGRect(x: 0, y: 8, width: 0, height: 0))
        self.assetLabel.text = AssetType.bitcoin.description
        self.assetLabel.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.ExtraExtraExtraSmall)
        self.assetLabel.textColor = Constants.Colors.ColorGray5
        self.assetLabel.sizeToFit()

        self.balanceLabel = BCInsetLabel(frame: CGRect(x: assetLabel.frame.origin.x + assetLabel.frame.size.width + 8, y: 4, width: 0, height: 0))
        self.balanceLabel.layer.cornerRadius = 5
        self.balanceLabel.layer.borderWidth = 1
        self.balanceLabel.textColor = Constants.Colors.ColorGray5
        self.balanceLabel.backgroundColor = Constants.Colors.ColorGray6
        self.balanceLabel.layer.borderColor = Constants.Colors.ColorGray2.cgColor
        self.balanceLabel.clipsToBounds = true
        self.balanceLabel.customEdgeInsets = UIEdgeInsets(top: 3.5, left: 11, bottom: 3.5, right: 11)
        self.balanceLabel.text = LocalizationConstants.AddressAndKeyImport.nonSpendable
        self.balanceLabel.font = UIFont(name: Constants.FontNames.montserratLight, size: Constants.FontSizes.ExtraExtraExtraSmall)

        super.init(frame: frame)

        self.addSubview(self.assetLabel)
        self.addSubview(self.balanceLabel)

        self.assetLabel.center = CGPoint(x: assetLabel.center.x, y: self.bounds.size.height/2)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func updateText(balance: String) {
        balanceLabel.text = balance + " " + LocalizationConstants.AddressAndKeyImport.nonSpendable
        balanceLabel.sizeToFit()
        balanceLabel.center = CGPoint(x: balanceLabel.center.x, y: assetLabel.center.y)

        // If balance text is so long that it goes past the edge, truncate the label and text
        let distancePastRightEdge = balanceLabel.frame.origin.x + balanceLabel.frame.size.width - self.bounds.size.width
        if distancePastRightEdge > 0 {
            balanceLabel.frame = CGRect(x: balanceLabel.frame.origin.x,
                                        y: balanceLabel.frame.origin.y,
                                        width: balanceLabel.frame.size.width - distancePastRightEdge,
                                        height: balanceLabel.frame.size.height)
        }
    }
}
