//
//  PrimaryButton.swift
//  Blockchain
//
//  Created by Maurice A. on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

public class PrimaryButton: UIButton {

    public override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
            super.alpha = alpha
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 4.0
    }

    override public func setTitle(_ title: String?, for state: UIControlState) {
        super.setTitle(title, for: state)
        titleLabel?.text = title
    }
}
