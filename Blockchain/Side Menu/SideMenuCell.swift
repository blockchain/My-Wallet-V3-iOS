//
//  SideMenuCell.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

final class SideMenuCell: UITableViewCell {
    
    fileprivate static let newContainerViewTrailingPadding: CGFloat = 16.0
    
    /// You must take into accoun the `peekAmount` of `ECSlidingViewController`
    /// otherwise the `newContainer` will not be visible.
    lazy var peekPadding: CGFloat = {
        let controller = AppCoordinator.shared.slidingViewController
        return controller.anchorRightPeekAmount
    }()

    static let defaultHeight: CGFloat = 54

    @IBOutlet fileprivate var title: UILabel!
    @IBOutlet fileprivate var icon: UIImageView!
    @IBOutlet fileprivate var newContainerView: UIView!
    @IBOutlet fileprivate var newLabel: UILabel!
    @IBOutlet fileprivate var newContainerTrailingConstraint: NSLayoutConstraint!
    
    var item: SideMenuItem? {
        didSet {
            title.text = item?.title
            icon.image = item?.image
            guard let value = item else {
                newContainerView.alpha = 0.0
                return
            }
            newContainerView.alpha = value.isNew ? 1.0 : 0.0
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        title.font = UIFont(
            name: Constants.FontNames.montserratRegular,
            size: Constants.FontSizes.Small
        )
        title.textColor = .black
        title.highlightedTextColor = .black
        newContainerView.layer.cornerRadius = 4.0
        newLabel.text = LocalizationConstants.SideMenu.new
        let padding = SideMenuCell.newContainerViewTrailingPadding
        guard newContainerTrailingConstraint.constant != padding + peekPadding else { return }
        newContainerTrailingConstraint.constant = padding + peekPadding
        setNeedsLayout()
        layoutIfNeeded()
    }
}
