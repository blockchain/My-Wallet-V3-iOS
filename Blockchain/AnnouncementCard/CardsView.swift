//
//  CardsView.swift
//  Blockchain
//
//  Created by Maurice A. on 9/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

class CardsView: UIView {

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        /**
          Legacy announcement cards do not yet support constraints
          - SeeAlso: IOS-1249 - Refactor CardsViewController
         */
        guard let announcementCard = subview as? AnnouncementCardView else {
            return
        }
        let margins = layoutMarginsGuide
        NSLayoutConstraint.activate([
            announcementCard.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            announcementCard.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            announcementCard.topAnchor.constraint(equalTo: margins.topAnchor),
            announcementCard.bottomAnchor.constraint(equalTo: margins.bottomAnchor)
        ])
    }
}
