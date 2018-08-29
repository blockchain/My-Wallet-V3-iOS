//
//  NumberInputViewModel.swift
//  Blockchain
//
//  Created by kevinwu on 8/27/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol NumberInputDelegate: class {
    var input: String? { get }
    func add(character: String)
    func addDecimal()
    func backspace()
}

// Class used to store the results of user input relayed by the NumberKeypadView.
class NumberInputViewModel: NumberInputDelegate {

    private(set) var input: String?

    init(newInput: String?) {
        input = newInput
    }

    func add(character: String) {
        // If current input is nil, set to character
        guard input != nil else {
            input = character
            return
        }
        input = input! + character
    }

    func addDecimal() {
        guard let decimalSeparator = Locale.current.decimalSeparator else {
            Logger.shared.warning("No decimal separator available")
            return
        }

        guard input != nil else {
            input = "0" + decimalSeparator
            return
        }

        guard !input!.contains(decimalSeparator) else {
            Logger.shared.debug("Decimal already exists")
            return
        }
    }

    func backspace() {
        guard input != nil else { return }
        input = String(input!.dropLast())
    }
}
