//
//  PlainCell.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

class PlainCell: BaseTableViewCell {

    // MARK: Class Properties

    fileprivate static let verticalPadding: CGFloat = 18.0
    fileprivate static let horizontalPadding: CGFloat = 16.0

    // MARK: Private IBOutlets

    @IBOutlet fileprivate var title: UILabel!

    // MARK: Overrides

    override func configure(with model: CellModel) {
        guard case let .plain(text) = model else { return }
        title.text = text
    }

    override class func heightForProposedWidth(_ width: CGFloat, model: CellModel) -> CGFloat {
        guard case let .plain(value) = model else { return 0.0 }
        let availableWidth = width - horizontalPadding
        let attributedTitle = NSAttributedString(string: value, attributes: [NSAttributedStringKey.font: titleFont()])
        let estimatedHeight = attributedTitle.heightForWidth(width: availableWidth)
        return estimatedHeight + verticalPadding + verticalPadding
    }

    static func titleFont() -> UIFont {
        return UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.SmallMedium) ?? UIFont.systemFont(ofSize: 17)
    }
}
