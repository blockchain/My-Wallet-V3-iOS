//
//  AssetTypeCell.swift
//  Blockchain
//
//  Created by kevinwu on 10/16/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc protocol AssetTypeCellDelegate {
    func didTapChevronButton()
}

// Cell shown for selecting an asset type from the drop-down
// menu (AssetSelectorView).
@objc class AssetTypeCell: UITableViewCell {

    @objc var legacyAssetType: LegacyAssetType {
        guard let asset = assetType else {
            Logger.shared.error("Unknown asset type!")
            return LegacyAssetType(rawValue: -1)!
        }
        return asset.legacy
    }
    private var assetType: AssetType?
    
    @objc weak var delegate: AssetTypeCellDelegate?
    
    @IBOutlet private var assetImageView: UIImageView!
    @IBOutlet private var label: UILabel!

    // Used to open and close the AssetSelectorView.
    @IBOutlet var chevronButton: UIButton!

    @objc func configure(with assetType: AssetType, showChevronButton: Bool) {
        self.assetType = assetType
        assetImageView.image = assetType.brandImage
        label.text = assetType.description
        chevronButton.isHidden = !showChevronButton
    }

    @IBAction private func chevronButtonTapped(_ sender: UIButton) {
        delegate?.didTapChevronButton()
    }
}

@objc extension AssetTypeCell {
    static func instanceFromNib() -> AssetTypeCell {
        let nib = UINib(nibName: "AssetTypeCell", bundle: Bundle.main)
        let contents = nib.instantiate(withOwner: nil, options: nil)
        return contents.first { item -> Bool in
            item is AssetTypeCell
        } as! AssetTypeCell
    }
}

@objc extension AssetTypeCell {
    func pointChevronButton(_ direction: Direction) {
        switch direction {
        case .up:
            UIView.animate(withDuration: Constants.Animation.duration) {
                self.chevronButton.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            }
        case .down:
            UIView.animate(withDuration: Constants.Animation.duration) {
                self.chevronButton.transform = CGAffineTransform(rotationAngle: 0)
            }
        }
    }
}
