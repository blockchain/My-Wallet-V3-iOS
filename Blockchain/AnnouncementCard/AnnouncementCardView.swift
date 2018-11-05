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

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var bodyLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var actionButton: UIButton!
    @IBOutlet private var closeButton: UIButton!

    // MARK: - Initialization

    @objc class func create(withModel model: AnnouncementCardViewModel) -> AnnouncementCardView {
        let cardView = AnnouncementCardView.makeFromNib()
        cardView.titleLabel.text = model.title
        cardView.bodyLabel.text = model.message
        cardView.imageView.image = model.image
        if let tint = model.imageTint {
            cardView.imageView.tintColor = tint
        }
        cardView.actionButton.setTitle(model.actionButtonTitle, for: .normal)
        cardView.actionButton.isHidden = (model.actionButtonTitle == nil)
        cardView.actionButtonPressed = model.action
        cardView.closeButtonPressed = model.onClose
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
        guard let close = closeButtonPressed else {
            Logger.shared.error("No action assigned to the close button!"); return
        }
        close()
    }
}
