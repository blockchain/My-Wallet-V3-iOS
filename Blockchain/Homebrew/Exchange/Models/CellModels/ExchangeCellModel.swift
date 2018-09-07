//
//  ExchangeCellModel.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

/// This is all the ViewModels used in all the cells
/// that are seen in the `ExchangeDetailViewController`
/// The models are nested given that it's possible models
/// similarly named could be used in other flows so, for the
/// time being we want to keep this specific to the `Exchange Details`
/// screen.
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
    
    /// Each model maps to a specific Cell.Type.
    /// All models should use an `ExchangeDetailCell`,
    /// and there are three subclasses of said cell.
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
