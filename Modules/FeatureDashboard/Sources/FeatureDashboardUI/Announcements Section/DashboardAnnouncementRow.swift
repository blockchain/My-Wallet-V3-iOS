// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import FeatureDashboardDomain
import Foundation
import SwiftUI
import UnifiedActivityDomain

public struct DashboardAnnouncementRow: Reducer {
    public let app: AppProtocol
    public init(
        app: AppProtocol
    ) {
        self.app = app
    }

    public enum Action: Equatable {}

    public struct State: Equatable, Identifiable {
        public var id: String {
            "\(announcement.id)"
        }

        var announcement: DashboardAnnouncement

        public init(
            announcement: DashboardAnnouncement
        ) {
            self.announcement = announcement
        }
    }

    public var body: some Reducer<State, Action> {
        EmptyReducer()
    }
}
