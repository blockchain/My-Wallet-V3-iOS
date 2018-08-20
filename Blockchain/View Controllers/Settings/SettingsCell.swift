//
//  SettingsCell.swift
//  Blockchain
//
//  Created by Justin on 7/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class ToggleCell: UIView, Togglable {
    @IBInspectable var cellTitle: String!
    @IBOutlet var toggleLabel: UILabel!
    @IBOutlet var toggleSwitch: UISwitch!
    
    func setup() {
        self.toggleLabel.text = cellTitle
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        toggleSwitch.removeFromSuperview()
    }
}

@IBDesignable class SettingsToggleTableViewCell: UITableViewCell, CustomToggleCell {
    var toggleSwitch: UISwitch!
    
    @IBInspectable var nibName: String? = "ToggleCell"
    @IBInspectable var cellTitle: String!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    func loadViewFromNib() -> ToggleCell? {
        guard let nibName = nibName else { return nil }
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(
            withOwner: self,
            options: nil).first as? ToggleCell
    }
    func xibSetup() {
        guard let view = loadViewFromNib() else { return }
        view.toggleLabel.text = cellTitle ?? ""
        view.toggleLabel.font = UIFont(name: Constants.FontNames.montserratLight, size: Constants.FontSizes.Medium)
        view.frame = bounds
        view.autoresizingMask =
            [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(view)
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        contentView.prepareForInterfaceBuilder()
        xibSetup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        xibSetup()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

@IBDesignable class SettingsTableViewBadge: SettingsTableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        let viewHeight = self.contentView.frame.size.height
        let labelHeight = self.detailTextLabel?.frame.size.height
        let ypos = (viewHeight / 2.0) - (labelHeight! / 2.0)
        self.detailTextLabel?.frame.origin.y = ypos
        let detailWidth =  self.detailTextLabel?.frame.size.width
        let screenWidth = UIScreen.main.bounds.width

        self.detailTextLabel?.frame.origin.x = screenWidth - detailWidth! - 40

        
        self.detailTextLabel?.font = UIFont(name: Constants.FontNames.montserratSemiBold, size: Constants.FontSizes.Tiny)

        
//        self.detailTextLabel?.layer.cornerRadius = 4
//        self.detailTextLabel?.layer.masksToBounds = true
//        self.detailTextLabel?.backgroundColor = .orange
//        self.detailTextLabel?.textColor = .white
//        sizeToFit()
//        layoutIfNeeded()
    
        
    }
}

@IBDesignable class SettingsTableViewCell: UITableViewCell, CustomSettingCell, CustomDetailCell {
    var subtitle: UILabel?
    var title: UILabel?
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        contentView.prepareForInterfaceBuilder()
        subtitle = detailTextLabel
        title = textLabel
        formatDetails()
        styleCell()
        mockCell()
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        styleCell()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
