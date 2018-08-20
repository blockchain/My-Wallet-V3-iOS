//
//  SettingsTableSectionHeader.swift
//  Blockchain
//
//  Created by Maurice A. on 8/17/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

class SettingsTableSectionHeader: UIView {

    // MARK: - IBOutlets

    @IBOutlet var label: UILabel!

    // MARK: - Setup

    override func awakeFromNib() {
        super.awakeFromNib()
        label.textColor = .gray5
    }
}
