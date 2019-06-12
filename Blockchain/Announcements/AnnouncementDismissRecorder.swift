//
//  AnnouncementDismissRecorder.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/12/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// A class that records dismiss actions taken by the user when dismissing an `Announcement`.
/// This is so that we can record if a user dismisses an `Announcement` so that we don't
/// show that announcement again.
class AnnouncementDismissRecorder {

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    subscript (_ key: String) -> Entry {
        return Entry(recorder: self, key: key)
    }

    class Entry {
        private unowned let recorder: AnnouncementDismissRecorder
        private let key: String

        var isDismissed: Bool {
            get {
                return recorder.userDefaults.bool(forKey: key)
            }
            set {
                recorder.userDefaults.set(newValue, forKey: key)
            }
        }

        init(recorder: AnnouncementDismissRecorder, key: String) {
            self.recorder = recorder
            self.key = key
        }
    }
}
