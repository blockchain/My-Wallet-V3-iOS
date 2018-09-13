//
//  ExchangeInputComponent.swift
//  Blockchain
//
//  Created by AlexM on 9/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct ExchangeInputComponents {
    var components: [InputComponent]
    var isUsingFiat: Bool {
        didSet {
            styleTemplate.type = isUsingFiat ? .fiat : .nonfiat
        }
    }
    private var styleTemplate: ExchangeStyleTemplate
    
    init(template: ExchangeStyleTemplate) {
        self.styleTemplate = template
        self.components = [
            InputComponent.start(
                with: template.primaryFont,
                textColor: template.textColor
            )
        ]
        isUsingFiat = styleTemplate.type == .fiat
    }
    
    mutating func append(_ component: InputComponent) {
        if components.count == 1 {
            if let first = components.first {
                if first.type == .whole && first.value == "0" {
                    components = [component]
                    return
                }
            }
        }
        components.append(component)
    }
    
    mutating func dropLast() {
        components = components.drop()
    }
    
    func primaryFiatAttributedString(_ symbolComponent: InputComponent) -> NSAttributedString {
        guard symbolComponent.type == .symbol else { return NSAttributedString(string: "NaN")}
        var reduced: [InputComponent] = components
        if components.contains(where: { $0.type == .fractional }) {
            reduced = components.filter({ $0.type != .pendingFractional })
        }
        let value = [symbolComponent] + reduced
        return value.map({ return $0.attributedString(with: styleTemplate )}).join()
    }
    
    func primaryAssetAttributedString(_ suffixComponent: InputComponent) -> NSAttributedString {
        guard suffixComponent.type == .suffix else { return NSAttributedString(string: "NaN")}
        let value = components + [suffixComponent]
        return value.map({ return $0.attributedString(with: styleTemplate )}).join()
    }
    
    var attributedString: NSAttributedString {
        return components.map({ return $0.attributedString(with: styleTemplate) }).join()
    }
}

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
            
            var attributes: [NSAttributedStringKey: Any] = [.font: font]
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
            
            var attributes: [NSAttributedStringKey: Any] = [.font: font,
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
        if count > 1 {
            return true
        } else {
            return false
        }
    }
    
    func drop() -> Array<Element> {
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

private extension String {
    
    var delimiter: String {
        return Locale.current.decimalSeparator ?? "."
    }
    
    var currencyDelimiterRange: NSRange? {
        /// Arabaic countries
        if let range = range(of: "١")?.asNSRange {
            return range
        }
        
        /// For EU countries
        if let range = range(of: ",")?.asNSRange {
            return range
        }
        
        /// For US
        if let range = range(of: ".")?.asNSRange {
            return range
        }
        
        return nil
    }
}

private extension Range where Bound == String.Index {
    var asNSRange: NSRange {
        return NSRange(
            location: self.lowerBound.encodedOffset,
            length: self.upperBound.encodedOffset - self.lowerBound.encodedOffset
        )
    }
}

