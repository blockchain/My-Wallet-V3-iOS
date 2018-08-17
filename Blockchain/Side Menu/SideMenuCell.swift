//
//  SideMenuCell.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

final class SideMenuCell: UITableViewCell {

    static let defaultHeight: CGFloat = 54

    var item: SideMenuItem? {
        didSet {
            self.textLabel?.text = item?.title
            self.imageView?.image = item?.image
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.textLabel?.font = UIFont(name: Constants.FontNames.montserratRegular, size: Constants.FontSizes.Small)
        self.textLabel?.textColor = .gray5
        self.textLabel?.highlightedTextColor = .gray5
        self.imageView?.contentMode = .scaleAspectFill
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let imageView = self.imageView else { return }
        guard let textLabel = self.textLabel else { return }
        let imageViewSize: CGFloat = 21
        imageView.frame = CGRect(
            x: 15,
            y: ((frame.height / 2) - (imageViewSize / 2)),
            width: imageViewSize,
            height: imageViewSize
        )
        textLabel.frame = CGRect(x: 55, y: textLabel.frame.minY, width: textLabel.frame.width, height: textLabel.frame.height)
    }
}
