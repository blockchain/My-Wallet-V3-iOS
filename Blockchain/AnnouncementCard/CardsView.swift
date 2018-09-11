//
//  CardsView.swift
//  Blockchain
//
//  Created by Maurice A. on 9/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

class CardsView: UIView {

    override var alignmentRectInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
