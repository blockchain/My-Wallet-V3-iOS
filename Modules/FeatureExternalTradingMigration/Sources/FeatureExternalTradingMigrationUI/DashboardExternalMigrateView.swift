// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import DIKit
import FeatureExternalTradingMigrationDomain
import Localization
import SwiftUI

private typealias L10n = LocalizationConstants.SuperApp.Dashboard.GetStarted.Trading
public struct DashboardExternalMigrateView: View {
    @Dependency(\.app) var app
    @StateObject var service = ExternalTradingMigrationService(
        app: resolve(),
        repository: resolve()
    )

    public init() {}

    @State var type: MigrationType?
    @State var userIsKycVerified: Bool?
    @State var migrationSuccessDismissed: Bool = false

    public var body: some View {
        Group {
            switch type {
            case .none:
                progressView
            case .inProgress:
                externalTradingMigrationInProgressView
            case .reviewTerms:
                externalTradingReviewTermsView
            case .upgrade:
                externalTradingUpgradeView
            case .complete:
                if migrationSuccessDismissed == false {
                    migrationSuccessAnnouncementCard
                }
            case .notAvailable:
                EmptyView()
            }
        }
        .bindings {
            subscribe(
                $migrationSuccessDismissed,
                to: blockchain.ux.dashboard.external.trading.migration.success.message.dismissed
            )
        }
        .batch {
            if userIsKycVerified == true {
                set(
                    blockchain.ux.dashboard.external.trading.migration.start.paragraph.button.primary.tap.then.enter.into,
                    to: blockchain.ux.dashboard.external.trading.migration
                )
            } else {
                set(
                    blockchain.ux.dashboard.external.trading.migration.start.paragraph.button.primary.tap.then.emit,
                    to: blockchain.ux.kyc.launch.verification
                )
            }
        }
        .batch {
            // for analytics purposes
            if let type, type != .notAvailable {
                set(
                    blockchain.ux.dashboard.external.trading.migration.notification.type,
                    to: type
                )
            }
        }
        .onAppear {
            app.post(event: blockchain.ux.dashboard.external.trading.migration.notification.shown)
        }
    }

    var progressView: some View {
        ProgressView()
            .task {
                let state = try? await app.get(
                    blockchain.api.nabu.gateway.user.external.brokerage.migration.state,
                    as: Tag.self
                )
                switch state {
                case blockchain.api.nabu.gateway.user.external.brokerage.migration.state.pending[]:
                    type = .inProgress
                case blockchain.api.nabu.gateway.user.external.brokerage.migration.state.complete[]:
                    type = .complete
                case blockchain.api.nabu.gateway.user.external.brokerage.migration.state.available[]:
                    let availableBalances = try? await service.fetchMigrationInfo()?.availableBalances
                    type = availableBalances?.isEmpty == true ? MigrationType.reviewTerms : MigrationType.upgrade

                default:
                    type = .notAvailable
                }
                userIsKycVerified = try? await app.get(blockchain.user.is.verified, as: Bool.self)
            }
    }

    var externalTradingMigrationInProgressView: some View {
        AlertCard(
            title: NonLocalizedConstants.Bakkt.bakktMigrationInProgressTitle,
            message: NonLocalizedConstants.Bakkt.bakktMigrationMessage,
            variant: .default,
            isBordered: true
        )
        .padding(.horizontal)
    }

    var externalTradingReviewTermsView: some View {
        AlertCard(
            title: NonLocalizedConstants.Bakkt.bakktStartMigrationNoAssetsTitle,
            message: NonLocalizedConstants.Bakkt.bakktStartMigrationNoAssetsMessage,
            variant: .warning,
            isBordered: true,
            footer: {
                HStack {
                    SmallSecondaryButton(
                        title: NonLocalizedConstants.Bakkt.bakktReviewTermsButton,
                        action: {
                            app.post(event: blockchain.ux.dashboard.external.trading.migration.start.paragraph.button.primary.tap)
                        }
                    )
                }
            }
        )
    }

    var externalTradingUpgradeView: some View {
        AlertCard(
            title: NonLocalizedConstants.Bakkt.bakktStartMigrationWithAssetsTitle,
            message: NonLocalizedConstants.Bakkt.bakktStartMigrationWithAssetsMessage,
            variant: .warning,
            isBordered: true,
            footer: {
                HStack {
                    SmallSecondaryButton(
                        title: NonLocalizedConstants.Bakkt.bakktUpgradeAccountButton,
                        action: {
                            app.post(event: blockchain.ux.dashboard.external.trading.migration.start.paragraph.button.primary.tap)
                        }
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        )
    }

    var migrationSuccessAnnouncementCard: some View {
        AnnouncementCard(
            title: NonLocalizedConstants.Bakkt.bakktMigrationSuccessAnnouncementCardTitle,
            message: NonLocalizedConstants.Bakkt.bakktMigrationSuccessAnnouncementCardMessage,
            background: {
                Color.semantic.background
            },
            onCloseTapped: {
                Task {
                    try? await app.set(blockchain.ux.dashboard.external.trading.migration.success.message.dismissed, to: true)
                }
            },
            leading: {
                Icon.user
            }
        )
    }
}

extension DashboardExternalMigrateView {
    public enum MigrationType: String {
        case notAvailable
        case upgrade
        case reviewTerms
        case inProgress
        case complete
    }
}
