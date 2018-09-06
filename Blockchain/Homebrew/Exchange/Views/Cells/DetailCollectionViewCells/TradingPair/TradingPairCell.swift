//
//  TradingPairCell.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

class TradingPairCell: ExchangeDetailCell {
    
    // MARK: Private Static Properties
    
    static fileprivate let verticalPadding: CGFloat = 16.0
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var tradingPairView: TradingPairView!
    
    // MARK: Overrides
    
    override func configure(with model: ExchangeCellModel) {
        guard case let .tradingPair(payload) = model else { return }
        tradingPairView.apply(model: payload.model)
    }
    
    override class func heightForProposedWidth(_ width: CGFloat, model: ExchangeCellModel) -> CGFloat {
        guard case .tradingPair = model else { return 0.0 }
        return TradingPairView.standardHeight + verticalPadding
    }
    
}
