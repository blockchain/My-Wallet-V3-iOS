//
//  SendXLMModelInterface.swift
//  Blockchain
//
//  Created by kevinwu on 10/25/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol SendXLMModelInterface: class {
    func updatePrice(_ value: Decimal)
    func updateXLMAmount(_ value: Decimal?)
    func updateFee(_ value: Decimal)
    func updateBaseReserve(_ value: Decimal?)
}
