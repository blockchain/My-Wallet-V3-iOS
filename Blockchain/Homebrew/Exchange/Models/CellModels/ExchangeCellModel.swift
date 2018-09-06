//
//  PlainCellModel.swift
//  Blockchain
//
//  Created by AlexM on 9/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

enum ExchangeCellModel {
    
    case plain(Plain)
    case text(Text)
    case tradingPair(TradingPair)
    
    struct Plain {
        let description: String
        let value: String
        let backgroundColor: UIColor
        let statusVisibility: Visibility
        let bold: Bool
        
        init(description: String, value: String, backgroundColor: UIColor = .white, statusVisibility: Visibility = .hidden, bold: Bool = false) {
            self.description = description
            self.value = value
            self.backgroundColor = backgroundColor
            self.statusVisibility = statusVisibility
            self.bold = bold
        }
    }
    
    struct Text {
        let attributedString: NSAttributedString
    }
    
    struct TradingPair {
        let model: TradingPairView.Model
    }
}

extension ExchangeCellModel {
    var reuseIdentifier: String {
        return cellType().identifier
    }
    
    func cellType() -> ExchangeDetailCell.Type {
        switch self {
        case .plain:
            return PlainCell.self
        case .text:
            return TextCell.self
        case .tradingPair:
            return TradingPairCell.self
        }
    }
    
    func heightForProposed(width: CGFloat) -> CGFloat {
        return cellType().heightForProposedWidth(
            width,
            model: self
        )
    }
}
