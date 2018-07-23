//
//  BCSecureTextField.swift
//  Blockchain
//
//  Created by Kevin Wu on 8/14/15.
//  Copyright (c) 2015 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

@objc class BCSecureTextField: UITextField {

    init() {
        super.init(frame: CGRect.zero)
        autocorrectionType = .no
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        autocorrectionType = .no
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        autocorrectionType = .no
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        autocorrectionType = .no
    }

    @objc func setupOnePixelLine() {
        if self.superview == nil {
            return
        }

        let onePixelHeight = 1.0/UIScreen.main.scale
        let onePixelLine = UIView(frame: CGRect(x: 0, y: self.frame.size.height - onePixelHeight,
                                                width: self.frame.size.width + 15, height: onePixelHeight))
        onePixelLine.frame = self.superview!.convert(onePixelLine.frame, from: self)
        onePixelLine.isUserInteractionEnabled = false
        onePixelLine.backgroundColor = .gray2
        self.superview!.addSubview(onePixelLine)
    }
}
