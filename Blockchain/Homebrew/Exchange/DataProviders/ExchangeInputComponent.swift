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

