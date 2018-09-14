//
//  AnnouncementCard.swift
//  Blockchain
//
//  Created by Maurice A. on 9/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

final class AnnouncementCard: NSObject {

    typealias Action = () -> Void

    // MARK: Properties

    @objc var view: AnnouncementCardView?

    // MARK: - Initialization

    @objc init(title: String, message: String, actionButtonTitle: String, image: UIImage, action: @escaping Action, onClose: @escaping Action) {
        super.init()
        guard let nib = Bundle.main.loadNibNamed("AnnouncementCardView", owner: self, options: nil),
            let contentView = nib.first as? AnnouncementCardView else {
                fatalError("🛑 Failed to load AnnouncementCard content view!")
        }
        contentView.titleLabel.text = title
        contentView.bodyLabel.text = message
        contentView.imageView.image = image
        contentView.actionButton.setTitle(actionButtonTitle, for: .normal)
        contentView.actionButtonPressed = action
        contentView.closeButtonPressed = onClose
        self.view = contentView
    }
}
