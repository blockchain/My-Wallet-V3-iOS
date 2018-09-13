//
//  ExchangeStyleTemplate.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct ExchangeStyleTemplate {
    let primaryFont: UIFont
    let secondaryFont: UIFont
    let textColor: UIColor
    let pendingColor: UIColor
    var type: InputType
    
    enum InputType {
        case fiat
        case nonfiat
    }
    
    init(primaryFont: UIFont, secondaryFont: UIFont, textColor: UIColor, pendingColor: UIColor, type: InputType = .fiat) {
        self.primaryFont = primaryFont
        self.secondaryFont = secondaryFont
        self.textColor = textColor
        self.pendingColor = pendingColor
        self.type = type
    }
    
    var offset: CGFloat {
        return primaryFont.capHeight - secondaryFont.capHeight
    }
    
    private static let primary = UIFont(
        name: ExchangeCreateViewController.primaryFontName,
        size: ExchangeCreateViewController.primaryFontSize
        ) ?? UIFont.systemFont(ofSize: 17.0)
    
    private static let secondary = UIFont(
        name: ExchangeCreateViewController.secondaryFontName,
        size: ExchangeCreateViewController.secondaryFontSize
        ) ?? UIFont.systemFont(ofSize: 17.0)
    
    static let standard: ExchangeStyleTemplate = ExchangeStyleTemplate(
        primaryFont: primary,
        secondaryFont: secondary,
        textColor: .brandPrimary,
        pendingColor: UIColor.brandPrimary.withAlphaComponent(0.5),
        type: .fiat
    )
}
