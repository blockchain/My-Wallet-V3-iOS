//
//  PrimaryButton.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

public class PrimaryButton: UIButton {

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 4.0
    }

    override public func setTitle(_ title: String?, for state: UIControlState) {
        super.setTitle(title, for: state)
        self.titleLabel?.text = title
    }
}
