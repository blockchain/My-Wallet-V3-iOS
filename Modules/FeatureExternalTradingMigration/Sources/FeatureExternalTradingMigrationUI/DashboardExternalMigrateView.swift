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

    public var body: some View {
        Group {
            switch type {
            case .inProgress:
                externalTradingMigrationInProgressView
            case .reviewTerms:
                externalTradingReviewTermsView
            case .upgrade:
                externalTradingUpgradeView
            case .none:
                progressView
            }
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
                let migrationInfo = try? await service.fetchMigrationInfo()
                if migrationInfo?.state == .pending {
                    type = .inProgress
                } else if let availableBalances = migrationInfo?.availableBalances {
                    type = availableBalances.isEmpty ? MigrationType.reviewTerms : MigrationType.upgrade
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
}

extension DashboardExternalMigrateView {
    public enum MigrationType {
        case upgrade
        case reviewTerms
        case inProgress
    }
}
