// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import FeatureDashboardDomain
import FeatureProductsDomain
import Foundation
import Localization
import PlatformKit

public struct DashboardAnnouncementsSection: ReducerProtocol {
    public let app: AppProtocol
    public let recoverPhraseProviding: RecoveryPhraseStatusProviding

    private typealias L10n = LocalizationConstants.Dashboard.Announcements

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
        var isEmpty: Bool {
            announcementsCards.isEmpty
        }

        public init(announcementsCards: IdentifiedArrayOf<DashboardAnnouncementRow.State> = []) {
            self.announcementsCards = announcementsCards
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return recoverPhraseProviding
                    .isRecoveryPhraseVerified
                    .combineLatest(
                        app
                            .publisher(
                                for: blockchain.api.nabu.gateway.user.products.product[ProductIdentifier.useTradingAccount].is.eligible,
                                as: Bool.self
                            )
                            .compactMap(\.value)
                    )
                    .receive(on: DispatchQueue.main)
                    .eraseToEffect()
                    .map { backedUp, tradingEnabled in
                        if backedUp == false {
                            let tag = blockchain.ux.home.dashboard.announcement.backup.seed.phrase
                            let result = Result<[DashboardAnnouncement], Never>.success(
                                [
                                    DashboardAnnouncement(
                                        id: UUID().uuidString,
                                        title: tradingEnabled ? L10n.recoveryPhraseBackupTitle : L10n.DeFiOnly.title,
                                        message: tradingEnabled ? L10n.recoveryPhraseBackupMessage : L10n.DeFiOnly.message,
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
            DashboardAnnouncementRow(app: app)
        }
    }
}
