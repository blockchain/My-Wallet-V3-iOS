//
//  TransactionDetail.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 11/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct TransactionDetail {
    let description: String
    let value: String
    let backgroundColor: UIColor
    let statusVisibility: Visibility
    let statusTintColor: UIColor
    let bold: Bool
    
    init(
        description: String,
        value: String,
        backgroundColor: UIColor = .white,
        statusVisibility: Visibility = .hidden,
        bold: Bool = false,
        statusTintColor: UIColor = .green
        ) {
        self.description = description
        self.value = value
        self.backgroundColor = backgroundColor
        self.statusVisibility = statusVisibility
        self.bold = bold
        self.statusTintColor = statusTintColor
    }
}
