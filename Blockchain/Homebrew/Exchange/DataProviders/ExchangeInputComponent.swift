//
//  ExchangeInputComponent.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

class ExchangeInputViewModel {
    var components: [InputComponent] = [.zero]
    var inputType: InputType {
        didSet {
            /// When we update the `inputType` we should `clear` the current
            /// array of components. If you know the current conversion value
            /// you should call `updateInput(inputType:with:latestConversion)`
            /// and pass in the conversion value. That will regenerate the components
            /// to reflect the converted value.
            clear()
        }
    }
    
    init(inputType: InputType) {
        self.inputType = inputType
    }
    
    func clear() {
        components = [.zero]
    }
    
    func update(inputType: InputType, with latestConversion: String) {
        self.inputType = inputType
        for character in latestConversion {
            append(character: character)
        }
    }
    
    func currentValue(includingSymbol: Bool = true) -> String {
        var dropped = components
        if components.count > 1 {
            if components.filter({ $0.type == .whole }).count != 1 && components.first == .zero {
                dropped = Array(components.dropFirst())
            }
        }
        switch inputType {
        case .fiat:
            var value = dropped.map({ $0.value }).joined()
            if dropped.contains(.delimiter), dropped.contains(where: { $0.type == .tenths }) == false {
                value += "0"
            }
            guard includingSymbol == true else { return value }
            let fiat = BlockchainSettings.App.shared.fiatCurrencySymbol + value
            return fiat
        case .nonfiat(let assetType):
            var value = dropped.map({ $0.value }).joined()
            if dropped.contains(.delimiter), dropped.contains(where: { $0.type == .fractional }) == false {
                value += "0"
            }
            guard includingSymbol == true else { return value }
            let symbol = assetType.symbol
            return value + " " + symbol
        }
    }
    
    func fiatValue() -> FiatValue? {
        guard inputType == .fiat else { return nil }
        let value = components.map({ $0.value }).joined()
        return FiatValue.create(amountString: value, currencyCode: BlockchainSettings.App.shared.fiatCurrencyCode)
    }
    
    func cryptoValue() -> CryptoValue? {
        guard case let .nonfiat(currency) = inputType else { return nil }
        let value = components.map({ $0.value }).joined()
        return CryptoValue.createFromMajorValue(string: value, assetType: currency)
    }
    
    func canAppend(character: Character) -> Bool {
        guard let inputComponent = componentForCharacter(String(character)) else { return false }
        return canAppend(component: inputComponent)
    }
    
    func canAppendDelimiter() -> Bool {
        return canAppend(component: .delimiter)
    }
    
    func append(character: Character) {
        guard let type = inputComponentTypeForCharacter(String(character)) else { return }
        let entry: InputComponentEntry = character == "0" ? .zero(String(character)) : .nonzero(String(character))
        let component = InputComponent(entry: entry, type: type)
        guard canAppend(component: component) == true else { return }
        append(component: component)
    }
    
    func appendDelimiter() {
        guard canAppend(component: .delimiter) else { return }
        append(component: .delimiter)
    }
    
    func dropLast() {
        guard canDrop() == true else { return }
        components = components.drop()
    }
    
    func canDrop() -> Bool {
        return components.canDrop
    }
    
    // MARK: Private Functions
    
    fileprivate func append(component: InputComponent) {
        guard canAppend(component: component) == true else { return }
        components.append(component)
    }
    
    fileprivate func canAppend(component: InputComponent) -> Bool {
        switch component.type {
        case .whole:
            if let first = components.first, first == .zero, component == .zero {
                /// `00` is an invalid entry. The current display value is already `0`
                /// If there's more than 1 component, that means other `whole` values
                /// have been entered and accepted, so additional whole values are fine.
                if components.count == 1 {
                    return false
                }
            }
            let wholes = components.filter({ $0.type == .whole })
            return wholes.count <= inputType.maxIntegerPlaces
        case .delimiter:
            return components.contains(where: { $0 == .delimiter }) == false
        case .fractional:
            guard inputType != .fiat else {
                assertionFailure(".fractional should not be used for for fiat")
                return false
            }
            guard let first = components.first else {
                assertionFailure("There should be a .whole component prior to adding a fractional")
                return false
            }
            guard first.type == .whole else { return false }
            guard components.contains(where: {$0 == .delimiter }) == true else {
                assertionFailure("A delimiter type must be added prior to adding fractionals")
                return false }
            let fractionals = components.filter({ $0.type == .fractional })
            guard fractionals.count <= inputType.maxFractionalPlaces else { return false }
            return true
        case .tenths:
            guard inputType == .fiat else {
                assertionFailure(".tenths should not be used for for nonFiat")
                return false
            }
            return components.contains(where: { $0.type == .tenths }) == false
        case .hundredths:
            guard inputType == .fiat else {
                assertionFailure(".hundredths should not be used for for nonFiat")
                return false
            }
            return components.contains(where: { $0.type == .hundredths }) == false
        }
    }
    
    fileprivate func componentForCharacter(_ character: String) -> InputComponent? {
        guard let type = inputComponentTypeForCharacter(character) else { return nil }
        let entry: InputComponentEntry = character == "0" ? .zero(character) : .nonzero(character)
        let component = InputComponent(entry: entry, type: type)
        return component
    }
    
    fileprivate func inputComponentTypeForCharacter(_ character: String) -> InputComponentType? {
        
        if character == Locale.current.decimalSeparator ?? "." {
            return components.contains(.delimiter) ? nil : .delimiter
        }
        
        let wholeCount = components.filter({ $0.type == .whole }).count
        
        switch inputType {
        case .fiat:
            if components.contains(.delimiter) == false {
                return wholeCount < inputType.maxIntegerPlaces ? .whole : nil
            } else if components.contains(where: { $0.type == .tenths }) == false {
                return .tenths
            } else if components.contains(where: { $0.type == .hundredths }) == false {
                return .hundredths
            } else {
                return nil
            }
        case .nonfiat:
            if components.contains(.delimiter) == false {
                return wholeCount < inputType.maxIntegerPlaces ? .whole : nil
            } else if components.filter({ $0.type == .fractional }).count < inputType.maxFractionalPlaces {
                return .fractional
            } else {
                return nil
            }
        }
    }
}
