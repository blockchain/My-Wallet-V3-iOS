//
//  AnnouncementList.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// A list of announcements that should be presented to the user
class AnnouncementList<P: AnnouncementPresenter> {

    private var announcements = [AnyAnnouncement<P>]()
    private weak var presenter: P?

    init(presenter: P) {
        self.presenter = presenter
    }

    @discardableResult func add(announcement: AnyAnnouncement<P>) -> AnnouncementList {
        announcements.append(announcement)
        return self
    }

    func showNextAnnouncement() -> AnyAnnouncement<P>? {
        guard let announcementToShow = announcements.first(where: { $0.shouldShow }) else {
            return nil
        }
        if let presenter = presenter {
            announcementToShow.show(presenter)
        }
        return announcementToShow
    }
}
