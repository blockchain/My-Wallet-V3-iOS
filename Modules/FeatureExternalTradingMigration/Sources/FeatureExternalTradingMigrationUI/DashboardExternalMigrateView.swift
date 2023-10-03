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
    }

    var progressView: some View {
        ProgressView()
            .task {
                let state = try? await app.get(blockchain.api.nabu.gateway.user.external.brokerage.migration.state, as: Tag.self)
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
            title: L10n.bakktMigrationInProgressTitle,
            message: L10n.bakktMigrationMessage,
            variant: .default,
            isBordered: true
        )
        .padding(.horizontal)
    }

    var externalTradingReviewTermsView: some View {
        AlertCard(
            title: L10n.bakktStartMigrationNoAssetsTitle,
            message: L10n.bakktStartMigrationNoAssetsMessage,
            variant: .warning,
            isBordered: true,
            footer: {
                HStack {
                    SmallSecondaryButton(
                        title: L10n.bakktReviewTermsButton,
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
            title: L10n.bakktStartMigrationWithAssetsTitle,
            message: L10n.bakktStartMigrationWithAssetsMessage,
            variant: .warning,
            isBordered: true,
            footer: {
                HStack {
                    SmallSecondaryButton(
                        title: L10n.bakktUpgradeAccountButton,
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
            title: L10n.bakktMigrationSuccessAnnouncementCardTitle,
            message: L10n.bakktMigrationSuccessAnnouncementCardMessage,
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
        .padding(.horizontal, Spacing.padding2)
    }
}

extension DashboardExternalMigrateView {
    public enum MigrationType {
        case notAvailable
        case upgrade
        case reviewTerms
        case inProgress
        case complete
    }
}