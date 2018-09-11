//
//  AnnouncementCard.swift
//  Blockchain
//
//  Created by Maurice A. on 9/7/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

final class AnnouncementCard: NSObject {

    // MARK: - Private Properties

    private let title: String
    private let message: String
    private let image: UIImage
    private let actionButtonTitle: String
    @objc private let actionButtonPressed: () -> Void

    // MARK: Public Properties

    @objc var view: AnnouncementCardView?

    // MARK: - Initialization

    @objc init(title: String, message: String, actionButtonTitle: String, image: UIImage, actionButtonPressed: @escaping () -> Void) {
        self.title = title
        self.message = message
        self.image = image
        self.actionButtonPressed = actionButtonPressed
        self.actionButtonTitle = actionButtonTitle
        super.init()
        setupView()
    }

    private func setupView() {
        guard let nib = Bundle.main.loadNibNamed("AnnouncementCardView", owner: self, options: nil),
            let contentView = nib.first as? AnnouncementCardView else {
            fatalError("🛑 Failed to load AnnouncementCard content view!")
        }
        contentView.titleLabel.text = title
        contentView.bodyLabel.text = message
        contentView.imageView.image = image
        contentView.actionButton.setTitle(actionButtonTitle, for: .normal)
        contentView.actionButton.addTarget(self, action: #selector(getter: AnnouncementCard.actionButtonPressed), for: .touchUpInside)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view = contentView
    }
}
