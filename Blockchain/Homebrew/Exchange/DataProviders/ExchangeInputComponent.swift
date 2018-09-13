//
//  ExchangeInputComponent.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/11/18.
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
    
    mutating func convertComponents(with value: String) {
        
        let delimiter = NumberFormatter.localCurrencyFormatter.decimalSeparator ?? "."
        /// This value is coming in as fiat
        /// but needs to be broken down into `[InputComponent]`
        let stringComponents = value.components(separatedBy: delimiter)
        
        if let first = stringComponents.first, stringComponents.count == 1 {
            components = [InputComponent(value: first, type: .whole)]
            return
        }
        
        guard stringComponents.count == 2 else {
            assertionFailure("You shouldn't have more than two strings here.")
            return
        }
        
        guard let first = stringComponents.first else { return }
        guard let second = stringComponents.last else { return }
        let whole = first.map({ return InputComponent(value: String($0), type: .whole) })
        let pending = InputComponent(value: delimiter, type: .pendingFractional)
        let fractional = second.map({ return InputComponent(value: String($0), type: .fractional) })
        switch isUsingFiat {
        case true:
            components = whole + fractional
        case false:
            components = whole + [pending] + fractional
        }
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

