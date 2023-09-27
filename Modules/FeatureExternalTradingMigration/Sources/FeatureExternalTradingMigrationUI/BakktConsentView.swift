// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainUI
import Localization
import SwiftUI

struct BakktConsentView: View {
    @Dependency(\.app) var app
    typealias L10n = LocalizationConstants.ExternalTradingMigration.Consent
    var hasAssetsToConsolidate: Bool = false
    var onDone: (() -> Void)?
    var onContinue: (() -> Void)?
    var continueButtonEnabled: Bool {
        consentItems.allSatisfy(\.isApproved)
    }

    @State var consentItems: [MigrationConsentElement]

    init(
        hasAssetsToConsolidate: Bool,
        onDone: (() -> Void)? = nil,
        onContinue: (() -> Void)? = nil
    ) {
        self.hasAssetsToConsolidate = hasAssetsToConsolidate
        self.consentItems = hasAssetsToConsolidate ?
        [
            MigrationConsentElement(type: .supportedAssets),
            MigrationConsentElement(type: .transactions),
            MigrationConsentElement(type: .migrationPeriod),
            MigrationConsentElement(type: .historicalData),
            MigrationConsentElement(type: .defiWallet)
        ] :
        [
            MigrationConsentElement(type: .transactions),
            MigrationConsentElement(type: .migrationPeriod),
            MigrationConsentElement(type: .historicalData),
            MigrationConsentElement(type: .defiWallet)
        ]

        self.onDone = onDone
        self.onContinue = onContinue
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.padding3) {
                Image(
                    "blockchain_logo",
                    bundle: Bundle.featureExternalTradingMigration
                )
                .frame(width: 88)

                VStack(spacing: Spacing.padding1) {
                    Text(L10n.headerTitle)
                        .typography(.title3)
                        .foregroundColor(.semantic.title)

                    Text(L10n.headerDescription)
                        .typography(.body2)
                        .foregroundColor(.semantic.text
                        )
                        .multilineTextAlignment(.center)

                    if hasAssetsToConsolidate {
                        SmallMinimalButton(title: LocalizationConstants.ExternalTradingMigration.learnMoreButton) {}
                    }
                }

                VStack(spacing: 0) {
                    ForEach($consentItems, id: \.id) { item in
                        ExpandingTableRow(item: item)
                    }
                }
                .background(.white)
                .cornerRadius(16, corners: .allCorners)

                Spacer()

                VStack(spacing: Spacing.padding2) {
                    termsAndConditions
                    if hasAssetsToConsolidate {
                        PrimaryButton(title: LocalizationConstants.ExternalTradingMigration.continueButton, action: {
                            onContinue?()
                        })
                        .disabled(!continueButtonEnabled)
                    } else {
                        PrimaryButton(
                            title: LocalizationConstants.ExternalTradingMigration.upgradeButton,
                            action: {
                            onDone?()
                        })
                        .disabled(!continueButtonEnabled)
                    }
                }
            }
            .padding(Spacing.padding2)
        }
        .navigationBarHidden(true)
        .superAppNavigationBar(leading: {},
                               trailing: {
            IconButton(icon: .navigationCloseButton()) {
                app.post(event: blockchain.ux.dashboard.external.trading.migration.article.plain.navigation.bar.button.close.tap)
            }
        }, scrollOffset: nil)
        .background(Color.semantic.light.ignoresSafeArea())
        .batch {
            set(blockchain.ux.dashboard.external.trading.migration.article.plain.navigation.bar.button.close.tap.then.close, to: true)
        }
    }

    @ViewBuilder var termsAndConditions: some View {
        Text(
            hasAssetsToConsolidate ?
            L10n.disclaimerItemsToConsolidate :
                L10n.disclaimerNoItemsToConsolidate
        )
        .typography(.micro)
        .foregroundColor(.semantic.body)
    }
}

//#Preview {
//    BakktConsentView(hasAssetsToConsolidate: false)
//}
//
//#Preview {
//    BakktConsentView(hasAssetsToConsolidate: true)
//}

struct MigrationConsentElement: Identifiable {
    let id = UUID()
    let type: MigrationConsentItem
    var isApproved: Bool = false

    init(type: MigrationConsentItem) {
        self.type = type
    }

    var title: String {
        switch type {
        case .supportedAssets:
            return LocalizationConstants.ExternalTradingMigration.Consent.SupportedAssets.title
        case .transactions:
            return LocalizationConstants.ExternalTradingMigration.Consent.EnchancedTransactions.title

        case .migrationPeriod:
            return LocalizationConstants.ExternalTradingMigration.Consent.MigrationPeriod.title
        case .historicalData:
            return LocalizationConstants.ExternalTradingMigration.Consent.HistoricalData.title
        case .defiWallet:
            return LocalizationConstants.ExternalTradingMigration.Consent.DefiWallet.title
        }
    }

    var message: String {
        switch type {
        case .supportedAssets:
            return LocalizationConstants.ExternalTradingMigration.Consent.SupportedAssets.message
        case .transactions:
            return LocalizationConstants.ExternalTradingMigration.Consent.EnchancedTransactions.message

        case .migrationPeriod:
            return LocalizationConstants.ExternalTradingMigration.Consent.MigrationPeriod.message
        case .historicalData:
            return LocalizationConstants.ExternalTradingMigration.Consent.HistoricalData.message
        case .defiWallet:
            return LocalizationConstants.ExternalTradingMigration.Consent.DefiWallet.message
        }
    }
}

enum MigrationConsentItem: String, CaseIterable {
    case supportedAssets
    case transactions
    case migrationPeriod
    case historicalData
    case defiWallet

    var title: String {
        switch self {
        case .supportedAssets:
            return LocalizationConstants.ExternalTradingMigration.Consent.SupportedAssets.title
        case .transactions:
            return LocalizationConstants.ExternalTradingMigration.Consent.EnchancedTransactions.title

        case .migrationPeriod:
            return LocalizationConstants.ExternalTradingMigration.Consent.MigrationPeriod.title
        case .historicalData:
            return LocalizationConstants.ExternalTradingMigration.Consent.HistoricalData.title
        case .defiWallet:
            return LocalizationConstants.ExternalTradingMigration.Consent.DefiWallet.title
        }
    }

    var description: String {
        switch self {
        case .supportedAssets:
            return LocalizationConstants.ExternalTradingMigration.Consent.SupportedAssets.message
        case .transactions:
            return LocalizationConstants.ExternalTradingMigration.Consent.EnchancedTransactions.message

        case .migrationPeriod:
            return LocalizationConstants.ExternalTradingMigration.Consent.MigrationPeriod.message
        case .historicalData:
            return LocalizationConstants.ExternalTradingMigration.Consent.HistoricalData.message
        case .defiWallet:
            return LocalizationConstants.ExternalTradingMigration.Consent.DefiWallet.message
        }
    }
}

struct ExpandingTableRow: View {
    @Binding var item: MigrationConsentElement
    @State var isExpanded: Bool = false
    @State private var rotationAngle: Double = 0

    var body: some View {
        TableRow(
            leading: {
                Checkbox(isOn: $item.isApproved)
            },
            title: { Text(item.title)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)
            },
            trailing: {
                let action = {
                    withAnimation {
                        isExpanded
                            .toggle()
                        rotationAngle = isExpanded ? 180 : 0
                    }
                }

                IconButton(icon: .chevronDown, action: action)
                    .rotationEffect(Angle(degrees: rotationAngle))
            },
            footer: {
                if isExpanded {
                    Text(item.message)
                        .typography(.caption1)
                        .foregroundColor(.semantic.body)
                }
            }
        )
    }
}
