//
//  AnnouncementCardViewModel.swift
//  Blockchain
//
//  Created by Maurice A. on 9/18/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@objc class AnnouncementCardViewModel: NSObject {
    typealias Action = () -> Void

    let title, message, actionButtonTitle: String
    let image: UIImage
    let action, onClose: Action

    @objc init(
        title: String,
        message: String,
        actionButtonTitle: String,
        image: UIImage,
        action: @escaping Action,
        onClose: @escaping Action) {
            self.title = title
            self.message = message
            self.actionButtonTitle = actionButtonTitle
            self.image = image
            self.action = action
            self.onClose = onClose
    }
}
