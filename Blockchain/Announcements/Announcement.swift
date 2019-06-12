//
//  Announcement.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Protocol definition of a presenter of an `Announcement`
protocol AnnouncementPresenter: class {
}

/// Protocol definition for an announcement shown to the user. These are typically
/// used by new products/features that we launch in the wallet.
protocol Announcement {
    associatedtype Presenter: AnnouncementPresenter

    var shouldShow: Bool { get }

    func show(_ presenter: Presenter)
}

final class AnyAnnouncement<P: AnnouncementPresenter>: Announcement {
    typealias Presenter = P

    private let showClosure: (P) -> Void
    var shouldShow: Bool

    init<A: Announcement>(announcement: A) where A.Presenter == P {
        self.shouldShow = announcement.shouldShow
        self.showClosure = announcement.show
    }

    func show(_ presenter: P) {
        showClosure(presenter)
    }
}
