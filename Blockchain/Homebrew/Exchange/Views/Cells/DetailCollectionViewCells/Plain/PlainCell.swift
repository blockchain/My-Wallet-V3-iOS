//
//  PlainCell.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

class PlainCell: ExchangeDetailCell {
    
    // MARK: Private Static Properties
    
    static fileprivate let horizontalPadding: CGFloat = 32.0
    static fileprivate let verticalPadding: CGFloat = 32.0
    
    // MARK: Private IBOutlets
    
    @IBOutlet fileprivate var subject: UILabel!
    @IBOutlet fileprivate var descriptionLabel: UILabel!
    @IBOutlet fileprivate var statusImageView: UIImageView!

    // MARK: Private Properties

    fileprivate var tapActionBlock: ExchangeCellModel.LabelAction?

    // MARK: Overrides
    
    override func configure(with model: ExchangeCellModel) {
        guard case let .plain(payload) = model else { return }
        
        layer.cornerRadius = 4.0
        subject.text = payload.description
        descriptionLabel.text = payload.value
        subject.font = payload.bold ? PlainCell.mediumFont() : PlainCell.standardFont()
        descriptionLabel.font = payload.bold ? PlainCell.mediumFont() : PlainCell.standardFont()
        backgroundColor = payload.backgroundColor
        subject.textColor = payload.bold ? .darkGray : #colorLiteral(red: 0.64, green: 0.64, blue: 0.64, alpha: 1)
        statusImageView.alpha = payload.statusVisibility.defaultAlpha
        statusImageView.tintColor = payload.statusTintColor

        if let action = payload.descriptionActionBlock {
            tapActionBlock = action
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(descriptionLabelTapped(sender:)))
            descriptionLabel.isUserInteractionEnabled = true
            descriptionLabel.addGestureRecognizer(tapGesture)
        }
    }
    
    override class func heightForProposedWidth(_ width: CGFloat, model: ExchangeCellModel) -> CGFloat {
        guard case let .plain(payload) = model else { return 0.0 }
        let description = NSAttributedString(
            string: payload.description,
            attributes: [NSAttributedString.Key.font: standardFont()]
        )
        
        let value = NSAttributedString(
            string: payload.value,
            attributes: [NSAttributedString.Key.font: standardFont()]
        )
        
        let availableWidth = width - horizontalPadding - description.width
        let height = value.heightForWidth(width: availableWidth) + verticalPadding
        
        return height
    }
    
    static func mediumFont() -> UIFont {
        return UIFont(
            name: Constants.FontNames.montserratMedium,
            size: 16.0
            ) ?? UIFont.systemFont(
                ofSize: 16,
                weight: .medium
        )
    }
    
    static func standardFont() -> UIFont {
        return UIFont(
            name: Constants.FontNames.montserratRegular,
            size: 16.0
            ) ?? UIFont.systemFont(
                ofSize: 16,
                weight: .regular
        )
    }

    @objc private func descriptionLabelTapped(sender: UITapGestureRecognizer) {
        if let action = tapActionBlock, let label = sender.view as? UILabel {
            action(label)
        }
    }
}
