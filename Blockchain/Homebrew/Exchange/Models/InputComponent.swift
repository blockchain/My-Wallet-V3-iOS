//
//  InputComponent.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class InputComponent {
    let value: String
    let type: InputComponentType
    
    init(value: String, type: InputComponentType) {
        self.value = value
        self.type = type
    }
}

extension InputComponent {
    static func start(with font: UIFont, textColor: UIColor) -> InputComponent {
        let start = InputComponent(
            value: "0",
            type: .whole
        )
        return start
    }
}

extension InputComponent {
    
    func attributedString(with style: ExchangeStyleTemplate) -> NSAttributedString {
        let primaryFont = style.primaryFont
        let secondaryFont = style.secondaryFont
        
        let offset = primaryFont.capHeight - secondaryFont.capHeight
        
        switch type {
        case .whole:
            return NSAttributedString(
                string: value,
                attributes: [.font: primaryFont]
            )
        case .fractional:
            
            let font = style.type == .fiat ? style.secondaryFont : style.primaryFont
            
            var attributes: [NSAttributedString.Key: Any] = [.font: font]
            if style.type == .fiat {
                attributes[.baselineOffset] = offset
            }
            
            return NSAttributedString(
                string: value,
                attributes: attributes
            )
        case .pendingFractional:
            
            let font = style.type == .fiat ? style.secondaryFont : style.primaryFont
            let color = style.type == .fiat ? style.pendingColor : style.textColor
            
            var attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                            .foregroundColor: color]
            if style.type == .fiat {
                attributes[.baselineOffset] = offset
            }
            
            return NSAttributedString(
                string: value,
                attributes: attributes
            )
        case .suffix:
            return NSAttributedString(
                string: value,
                attributes: [.font: primaryFont]
            )
        case .symbol:
            return NSAttributedString(
                string: value,
                attributes: [.font: secondaryFont,
                             .baselineOffset: offset]
            )
        case .space:
            return NSAttributedString(
                string: value,
                attributes: [.font: primaryFont]
            )
        }
    }
}

enum InputComponentType {
    case whole
    case fractional
    case pendingFractional
    case suffix
    case symbol
    case space
}

extension Array where Element == InputComponent {
    
    func canDrop() -> Bool {
        if let model = first, count == 1 {
            return model.value != "0"
        }
        return count > 1
    }
    
    func drop() -> [Element] {
        if count > 1 {
            return Array(dropLast())
        }
        if count == 1 {
            if let model = first, model.value == "0" {
                return self
            }
            if let model = first, model.value != "0" {
                let result = [InputComponent(value: "0", type: .whole)]
                return result
            }
        }
        return self
    }
}
