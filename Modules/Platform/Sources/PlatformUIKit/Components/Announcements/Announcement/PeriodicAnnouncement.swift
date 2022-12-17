// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// Rules for periodic announcement. this is useful to prevent starvation of other
/// announcements while only one displays constantly.
public struct PeriodicAnnouncementAppearanceRules {

    /// The time **in seconds** that the announcement remains hidden. after that
    /// time passes, the announcement should resurface again.
    let recessDurationBetweenDismissals: TimeInterval

    /// Max amount of dismissals before the announcement shuts down permanently
    let maxDismissalCount: Int

    /// Initialize the appearance rules for a periodic announcement
    ///
    /// - Parameter recessDurationBetweenDismissals: this is the time **in seconds** that the announcement remains hidden.
    /// after the time passes, the announcement should resurface.
    /// - Parameter maxDismissalCount: Amount of dismissals before the announcement shuts down permanently.
    /// this value defaults to `Int.max` unless another value was specificed.
    public init(recessDurationBetweenDismissals: TimeInterval, maxDismissalCount: Int = .max) {
        self.recessDurationBetweenDismissals = recessDurationBetweenDismissals
        self.maxDismissalCount = maxDismissalCount
    }
}

/// A periodic announcement is a dismissable announcement that keeps displaying up to its dismissal.
/// Once the announcement is dismissed by the user, it will resurface once
/// `PeriodicAnnouncementAppearanceRules` allows it again.
public protocol PeriodicAnnouncement: DismissibleAnnouncement {

    /// The rules for displaying a periodic announcement
    var appearanceRules: PeriodicAnnouncementAppearanceRules { get }

    /// Marks the announcement as dismissed.
    func markDismissed()
}

// MARK: - Default implementation of `PeriodicAnnouncement`

extension PeriodicAnnouncement {

    /// Default the category to periodic
    public var category: AnnouncementRecord.Category { .periodic }

    /// Returns a boolean indicating whether the announcement
    /// is in a `dismissed` state.
    public var isDismissed: Bool {
        switch recorder[key].displayState {
        case .conditional(lastDismissalDate: let date, dismissalsSoFar: let count):
            let nextAnnouncementDate = date.addingTimeInterval(appearanceRules.recessDurationBetweenDismissals)
            return nextAnnouncementDate > Date() || count >= appearanceRules.maxDismissalCount
        case .hide:
            return true
        case .show:
            return false
        }
    }

    /// Default implementation for announcement dismissal.
    /// The announcement is being marked as dismissed by the recorder.
    /// That means it can appear again if the appearance rules allow it.
    public func markDismissed() {
        recorder[key].markDismissed(category: category)
    }

    /// Returns an integer with the number of dismissals that have happened
    /// so far.
    public var dismissalsSoFar: Int {
        switch recorder[key].displayState {
        case .conditional(_, dismissalsSoFar: let count):
            return count
        default:
            return 0
        }
    }
}
