// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import FeatureDashboardDomain
import Foundation
import Localization
import PlatformKit

public struct DashboardAnnouncementsSection: ReducerProtocol {
    public let app: AppProtocol
    public let recoverPhraseProviding: RecoveryPhraseStatusProviding

    public init(
        app: AppProtocol,
        recoverPhraseProviding: RecoveryPhraseStatusProviding
    ) {
        self.app = app
        self.recoverPhraseProviding = recoverPhraseProviding
    }

    public enum Action: Equatable {
        case onAppear
        case onDashboardAnnouncementFetched(Result<[DashboardAnnouncement], Never>)
        case onAnnouncementTapped (
            id: DashboardAnnouncementRow.State.ID,
            action: DashboardAnnouncementRow.Action
        )
    }

    public struct State: Equatable {
        var announcementsCards: IdentifiedArrayOf<DashboardAnnouncementRow.State>
        public init(announcementsCards: IdentifiedArrayOf<DashboardAnnouncementRow.State> = []) {
            self.announcementsCards = announcementsCards
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return app.publisher(for: blockchain.user.skipped.seed_phrase.backup, as: Bool.self)
                    .map(\.value)
                    .replaceNil(with: false)
                    .combineLatest(recoverPhraseProviding.isRecoveryPhraseVerified)
                    .map { recoveryPhraseSkipped, recoveryPhraseBackedUp -> Bool in
                        let shouldDisplayAnnouncement = !(recoveryPhraseBackedUp || recoveryPhraseSkipped)
                        return shouldDisplayAnnouncement
                    }
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect()
                    .map { shouldDisplayAnnouncement in
                        if shouldDisplayAnnouncement == true {
                            let tag = blockchain.ux.home.dashboard.announcement.backup.seed.phrase
                            let result = Result<[DashboardAnnouncement], Never>.success(
                                [
                                    DashboardAnnouncement(
                                        id: UUID().uuidString,
                                        title: LocalizationConstants.Dashboard.Announcements.recoveryPhraseBackupTitle,
                                        message: LocalizationConstants.Dashboard.Announcements.recoveryPhraseBackupMessage,
                                        action: tag
                                    )
                                ]
                            )
                            return .onDashboardAnnouncementFetched(result)
                        } else {
                            return .onDashboardAnnouncementFetched(.success([]))
                        }
                    }

            case .onAnnouncementTapped:
                return .none

            case .onDashboardAnnouncementFetched(.success(let announcements)):
                let items = announcements
                    .map {
                        DashboardAnnouncementRow.State(
                            announcement: $0
                        )
                    }
                state.announcementsCards = IdentifiedArrayOf(uniqueElements: items)
                return .none
            }
        }
        .forEach(\.announcementsCards, action: /Action.onAnnouncementTapped) {
            DashboardAnnouncementRow(app: self.app)
        }
    }
}
