//
//  SendXLMInterface.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol SendXLMInterface: class {
    typealias PresentationUpdate = SendLumensViewController.PresentationUpdate
    func apply(updates: [PresentationUpdate])
}
