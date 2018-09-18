//
//  AnnouncementCardView.swift
//  Blockchain
//
//  Created by Maurice A. on 9/6/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

class AnnouncementCardView: UIView {

    typealias Action = () -> Void

    // MARK: - Properties

    var actionButtonPressed, closeButtonPressed: (() -> Void)?

    // MARK: - IBOutlets

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var actionButton: UIButton!
    @IBOutlet var closeButton: UIButton!

    // MARK: - Initialization

    // swiftlint:disable:next function_parameter_count
    @objc class func create(
        withTitle title: String,
        message: String,
        image: UIImage,
        actionButtonTitle: String,
        action: @escaping Action,
        onClose: @escaping Action) -> AnnouncementCardView {
            let cardView = AnnouncementCardView.makeFromNib()
            cardView.titleLabel.text = title
            cardView.bodyLabel.text = message
            cardView.imageView.image = image
            cardView.actionButton.setTitle(actionButtonTitle, for: .normal)
            cardView.actionButtonPressed = action
            cardView.closeButtonPressed = onClose
            return cardView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false
        closeButton.tintColor = .gray4
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.15
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }

    // MARK: - IBActions

    @IBAction private func actionButtonPressed(_ sender: Any) {
        guard let action = actionButtonPressed else {
            Logger.shared.error("No action assigned to the action button!"); return
        }
        action()
    }

    @IBAction private func closeButtonPressed(_ sender: Any) {
        guard let action = closeButtonPressed else {
            Logger.shared.error("No action assigned to the close button!"); return
        }
        action()
    }
}
