//
//  SendPAXInterface.swift
//  Blockchain
//
//  Created by AlexM on 5/10/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol SendPAXInterface: class {
    func apply(updates: Set<SendMoniesPresentationUpdate>)
    func display(confirmation: BCConfirmPaymentViewModel)
}
