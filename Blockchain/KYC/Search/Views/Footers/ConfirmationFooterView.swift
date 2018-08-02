//
//  ConfirmationFooterView.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/31/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

class ConfirmationFooterView: UITableViewHeaderFooterView {

    typealias ActionBlock = () -> Void

    // MARK: Private Constants

    fileprivate static let verticalPadding: CGFloat = 16.0
    fileprivate static let horizontalPadding: CGFloat = 20.0
    fileprivate static let buttonHeight: CGFloat = 44.0

    // MARK: Private IBOutlets

    @IBOutlet fileprivate var confirmButton: UIButton!

    // MARK: Public Properties

    var actionBlock: ActionBlock?

    // MARK: Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        confirmButton.backgroundColor = .brandSecondary
        confirmButton.layer.cornerRadius = 4.0
    }

    // MARK: Actions
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        guard let block = actionBlock else { return }
        block()
    }

    // MARK: Class Functions

    static func footerHeight() -> CGFloat {
        return buttonHeight + verticalPadding + verticalPadding
    }
}
