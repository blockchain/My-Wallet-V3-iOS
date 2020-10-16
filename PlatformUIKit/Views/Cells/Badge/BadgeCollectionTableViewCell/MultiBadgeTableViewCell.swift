//
//  MultiBadgeTableViewCell.swift
//  PlatformUIKit
//
//  Created by Paulo on 07/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

class MultiBadgeTableViewCell: UITableViewCell {

    // MARK: Private Properties

    private let multiBadgeView = MultiBadgeView()

    // MARK: - Public Properites

    public var model: MultiBadgeViewModel! {
        get { multiBadgeView.model }
        set { multiBadgeView.model = newValue }
    }

    // MARK: Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: Private Methods

    private func setup() {
        selectionStyle = .none
        contentView.addSubview(multiBadgeView)
        multiBadgeView.layoutToSuperview(.leading, .trailing, .top, .bottom)
    }
}
