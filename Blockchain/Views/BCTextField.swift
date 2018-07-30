//
//  BCTextField.swift
//  Blockchain
//
//  Created by Mark Pfluger on 6/26/15.
//  Copyright (c) 2015 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

class BCTextField: BCSecureTextField {

    override func awakeFromNib() {
        super.awakeFromNib()
        super.setupOnePixelLine()
    }

    override var frame: CGRect {
        didSet {
            super.setupOnePixelLine()
        }
    }
}
