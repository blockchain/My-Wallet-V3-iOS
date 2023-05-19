// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Blockchain
import BlockchainUI
import DIKit
import PlatformKit
import SwiftUI

private typealias L10n = LocalizationConstants.NewKYC.UnlockTrading

@MainActor
public struct SiteMap {

    let app: AppProtocol

    public init(app: AppProtocol) {
        self.app = app
    }

    @ViewBuilder public func view(
        for ref: Tag.Reference,
        in context: Tag.Context = [:]
    ) throws -> some View {
        switch ref {
        case blockchain.ux.kyc.trading.unlock.more:
            try UnlockTradingView(
                store: .init(
                    initialState: UnlockTradingState(currentUserTier: app.state.get(blockchain.user.is.verified) ? .verified : .unverified),
                    reducer: unlockTradingReducer,
                    environment: UnlockTradingEnvironment(
                        dismiss: {
                            app.post(event: blockchain.ux.kyc.trading.unlock.more.article.plain.navigation.bar.button.close.tap, context: context)
                        },
                        unlock: { _ in
                            app.post(event: blockchain.ux.kyc.launch.verification, context: context)
                        },
                        analyticsRecorder: resolve()
                    )
                )
            )
            .batch {
                set(blockchain.ux.kyc.trading.unlock.more.article.plain.navigation.bar.button.close.tap.then.close, to: true)
            }
        default:
            throw "Unknown View of \(ref) in \(Self.self)"
        }
    }
}

struct UnlockTradingView: View {

    let store: Store<UnlockTradingState, UnlockTradingAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: Spacing.padding2) {
                HStack(alignment: .top, spacing: Spacing.padding2) {
                    Image("icon-verified", bundle: .module)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .accentColor(.semantic.primary)
                        .foregroundColor(.semantic.primary)

                    VStack(alignment: .leading, spacing: Spacing.textSpacing) {
                        Text(L10n.title)
                            .typography(.body2)

                        Text(L10n.message)
                            .typography(.caption1)
                            .foregroundColor(.semantic.overlay)
                    }
                }

                ScrollView {
                    makeUpgradePrompt(
                        currentTier: viewStore.currentUserTier
                    )
                    .padding(.bottom, Spacing.padding2)
                }
            }
            .padding(.top, Spacing.padding2)
            .padding(.horizontal, Spacing.padding3)
            .primaryNavigation(
                title: L10n.navigationTitle,
                trailing: {
                    Icon.closeCirclev2
                        .onTapGesture {
                            viewStore.send(.closeButtonTapped)
                        }
                }
            )
        }
    }

    @ViewBuilder
    private func makeUpgradePrompt(
        currentTier: KYC.Tier
    ) -> some View {
        BenefitsView(
            store: store,
            targetTier: .verified,
            benefits: UnlockTradingBenefit.verifiedBenefits(active: currentTier >= .verified)
        )
        .promptColorScheme(.verified)
        .transition(
            .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            )
        )
    }
}

extension UnlockTradingView {

    func embeddedInNavigationView() -> some View {
        PrimaryNavigationView {
            self
        }
    }
}

private struct BenefitsView: View {

    @Environment(\.promptColorScheme) var colorScheme

    let store: Store<UnlockTradingState, UnlockTradingAction>
    let targetTier: KYC.Tier
    let benefits: [UnlockTradingBenefit]

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                VStack(alignment: .leading, spacing: .zero) {
                    let lastBenefit = benefits.last
                    ForEach(benefits) { benefit in
                        BenefitView(benefit: benefit)

                        if benefit != lastBenefit {
                            BenefitsDivider()
                        }
                    }
                }

                if viewStore.currentUserTier < targetTier {
                    let ctaTitle = L10n.cta_verified
                    DefaultButton(title: ctaTitle) {
                        viewStore.send(.unlockButtonTapped(targetTier))
                    }
                    .colorCombination(colorScheme.ctaColorCombination)
                    .padding(.top, Spacing.padding1) // last raw has padding already
                    .padding([.bottom, .horizontal], Spacing.padding3)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: Spacing.containerBorderRadius)
                    .fill(colorScheme.backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.containerBorderRadius)
                    .stroke(colorScheme.borderColor)
            )
            .padding(1) // border isn't displayed correctly otherwise :/
            .accentColor(colorScheme.accentColor)
            .foregroundColor(colorScheme.primaryTextColor)
        }
    }
}

private struct BenefitView: View {

    @Environment(\.promptColorScheme) var colorScheme

    let benefit: UnlockTradingBenefit

    var body: some View {
        HStack(spacing: Spacing.padding2) {
            Image(benefit.iconName, bundle: .module)
                .renderingMode(benefit.iconRenderingMode)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .accentColor(benefit.iconTint ?? colorScheme.accentColor)
                .foregroundColor(benefit.iconTint ?? colorScheme.primaryTextColor)

            VStack(alignment: .leading, spacing: Spacing.textSpacing) {
                Text(benefit.title)
                    .typography(.body2)

                if let message = benefit.message {
                    Text(message)
                        .typography(.paragraph1)
                        .foregroundColor(colorScheme.secondaryTextColor)
                }
            }

            Spacer()

            makeBadge()
        }
        .padding(.vertical, Spacing.padding2)
        .padding(.horizontal, Spacing.padding3)
    }

    @ViewBuilder
    private func makeBadge() -> some View {
        switch benefit.status {
        case .badge(let message):
            Text(message)
                .typography(.caption2)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(colorScheme.badgeColor)
                )

        case .enabled:
            Icon.check
                .renderingMode(.template)
                .frame(width: 24, height: 24)
        }
    }
}

private struct BenefitsDivider: View {

    var body: some View {
        PrimaryDivider()
    }
}

extension PillButtonStyle.ColorCombination {

    static let verifiedKYCPrompt = PillButtonStyle.ColorCombination(
        enabled: PillButtonStyle.ColorSet(
            foreground: .semantic.primary,
            background: .white,
            border: .white
        ),
        pressed: PillButtonStyle.ColorSet(
            foreground: .semantic.primary.opacity(0.8),
            background: .white.opacity(0.8),
            border: .white.opacity(0.8)
        ),
        disabled: PillButtonStyle.ColorSet(
            foreground: .primary.opacity(0.5),
            background: .white.opacity(0.5),
            border: .white.opacity(0.5)
        ),
        progressViewRail: .semantic.primary.opacity(0.8),
        progressViewTrack: .white.opacity(0.25)
    )
}

private struct PromptColorScheme {

    let accentColor: Color
    let badgeColor: Color
    let borderColor: Color
    let backgroundColor: Color
    let primaryTextColor: Color
    let secondaryTextColor: Color
    let ctaColorCombination: PillButtonStyle.ColorCombination

    static let basic = PromptColorScheme(
        accentColor: .semantic.primary,
        badgeColor: .semantic.light,
        borderColor: .semantic.light,
        backgroundColor: .semantic.background,
        primaryTextColor: .semantic.title,
        secondaryTextColor: .semantic.muted,
        ctaColorCombination: .primary
    )

    static let verified = PromptColorScheme(
        accentColor: .semantic.background,
        badgeColor: .white.opacity(0.24),
        borderColor: .semantic.primary,
        backgroundColor: .semantic.primary,
        primaryTextColor: .white,
        secondaryTextColor: .white,
        ctaColorCombination: .verifiedKYCPrompt
    )
}

private struct PromptColorSchemeKey: EnvironmentKey {

    static var defaultValue = PromptColorScheme.basic
}

extension EnvironmentValues {

    fileprivate var promptColorScheme: PromptColorScheme {
        get { self[PromptColorSchemeKey.self] }
        set { self[PromptColorSchemeKey.self] = newValue }
    }
}

extension View {

    fileprivate func promptColorScheme(_ colorScheme: PromptColorScheme) -> some View {
        environment(\.promptColorScheme, colorScheme)
    }
}

struct UnlockTradingView_Previews: PreviewProvider {

    static var previews: some View {
        UnlockTradingView(
            store: .init(
                initialState: UnlockTradingState(currentUserTier: .unverified),
                reducer: unlockTradingReducer,
                environment: .preview
            )
        )
    }
}
