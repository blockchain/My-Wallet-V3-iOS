// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKitMock
import ComposableArchitecture
import CoreMedia
import Errors
import FeatureNotificationPreferencesMocks
@testable import FeatureNotificationPreferencesUI
import Foundation
import SnapshotTesting
import TestKit
import XCTest

final class FeatureNotificationPreferencesSnapshotTests: XCTestCase {
    private let mainScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test
    private var notificationRepoMock: NotificationPreferencesRepositoryMock!
    private var rootStore: Store<NotificationPreferencesState, NotificationPreferencesAction>!

    override func setUpWithError() throws {
        try super.setUpWithError()

        isRecording = false

        let preferencesToReturn = [
            MockGenerator.marketingNotificationPreference,
            MockGenerator.transactionalNotificationPreference,
            MockGenerator.priceAlertNotificationPreference
        ]

        notificationRepoMock = NotificationPreferencesRepositoryMock()
        notificationRepoMock.fetchPreferencesSubject.send(preferencesToReturn)
    }

    override func tearDownWithError() throws {
        notificationRepoMock = nil
        try super.tearDownWithError()
    }
}
