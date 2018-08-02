//
//  TextEntry.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

struct TextEntry {
    let placeholder: String
    let shouldBecomeFirstResponder: Bool
    var submission: String? = nil
}
