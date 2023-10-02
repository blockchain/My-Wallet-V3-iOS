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

    @State var type: MigrationType = .reviewTerms

    public var body: some View {
        AlertCard(
            title: type.title,
            message: type.message,
            variant: .warning,
            isBordered: true,
            footer: {
                HStack {
                    SmallSecondaryButton(
                        title: type.ctaButton,
                        action: {
                            app.post(event: blockchain.ux.dashboard.external.trading.migration.start.paragraph.button.primary.tap)
                        }
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        )
        .task {
            let migrationInfo = try? await service.fetchMigrationInfo()
            if let availableBalances = migrationInfo?.availableBalances {
                type = availableBalances.isEmpty ? MigrationType.reviewTerms : MigrationType.upgrade
            }
        }
        .batch {
            set(
                blockchain.ux.dashboard.external.trading.migration.start.paragraph.button.primary.tap.then.enter.into,
                to: blockchain.ux.dashboard.external.trading.migration
            )
        }
    }
}

extension DashboardExternalMigrateView {
    public enum MigrationType {
        case upgrade
        case reviewTerms

        var title: String {
            switch self {
            case .upgrade:
                return L10n.bakktStartMigrationWithAssetsTitle
            case .reviewTerms:
                return L10n.bakktStartMigrationNoAssetsTitle
            }
        }

        var message: String {
            switch self {
            case .upgrade:
                return L10n.bakktStartMigrationWithAssetsMessage
            case .reviewTerms:
                return L10n.bakktStartMigrationNoAssetsMessage
            }
        }

        var ctaButton: String {
            switch self {
            case .upgrade:
                return L10n.bakktUpgradeAccountButton
            case .reviewTerms:
                return L10n.bakktReviewTermsButton
            }
        }
    }
}
