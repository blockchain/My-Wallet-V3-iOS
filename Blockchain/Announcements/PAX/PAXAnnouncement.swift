//
//  PAXAnnouncement.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class PAXAnnouncement: Announcement {

    typealias Presenter = CardsViewController

    private let dismissRecorder: AnnouncementDismissRecorder
    private var dismissEntry: AnnouncementDismissRecorder.Entry {
        return dismissRecorder[UserDefaults.Keys.hasSeenPAXCard.rawValue]
    }

    var shouldShow: Bool {
        return !dismissEntry.isDismissed
    }

    init(dismissRecorder: AnnouncementDismissRecorder) {
        self.dismissRecorder = dismissRecorder
    }

    func show(_ presenter: CardsViewController) {
        let viewModel = AnnouncementCardViewModel.paxIntro(action: { [weak self] in
            self?.dismissEntry.isDismissed = true
            let tabController = AppCoordinator.shared.tabControllerManager
            tabController.swapTapped(nil)
        }, onClose: { [weak self] in
            self?.dismissEntry.isDismissed = true
            presenter.animateHideCards()
        })
        presenter.showSingleCard(with: viewModel)
    }
}
