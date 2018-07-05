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
        self.assetLabel = UILabel(frame: CGRect.zero)
        self.assetLabel.text = LocalizationConstants.Assets.bitcoin
        self.assetLabel.sizeToFit()

        self.balanceLabel = BCInsetLabel(frame: CGRect(x: assetLabel.frame.origin.x + assetLabel.frame.size.width + 8, y: 0, width: 0, height: 0))
        self.balanceLabel.text = LocalizationConstants.AddressAndKeyImport.nonSpendable

        super.init(frame: frame)

        self.addSubview(self.assetLabel)
        self.addSubview(self.balanceLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func updateText(balance: String) {
        balanceLabel.text = LocalizationConstants.AddressAndKeyImport.nonSpendable + " " + balance
        balanceLabel.sizeToFit()
    }
}
