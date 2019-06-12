//
//  DashboardAnnouncements.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// All announcements that we prevent in our Dashboard. This is pretty tightly
/// coupled with `CardsViewController`
class DashboardAnnouncements {
    static let shared = DashboardAnnouncements()

    private let dismissRecorder = AnnouncementDismissRecorder(userDefaults: UserDefaults.standard)
    private var announcementsList: AnnouncementList<CardsViewController>?

    func announcements(presenter: CardsViewController) -> AnnouncementList<CardsViewController> {
        let paxAnnouncement = PAXAnnouncement(dismissRecorder: dismissRecorder)
        announcementsList = AnnouncementList<CardsViewController>(presenter: presenter)
            .add(announcement: AnyAnnouncement<CardsViewController>(announcement: paxAnnouncement))
        return announcementsList!
    }
}
