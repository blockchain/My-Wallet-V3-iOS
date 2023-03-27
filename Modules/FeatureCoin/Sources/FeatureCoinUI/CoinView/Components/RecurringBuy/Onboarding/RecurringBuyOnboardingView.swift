// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import FeatureCoinDomain
import Localization
import SwiftUI

enum RecurringBuyOnboardingScreens: Hashable, Identifiable, CaseIterable {
    case intro
    case strategy
    case marketUp
    case marketDown
    case final

    private typealias L10n = LocalizationConstants.Coin.RecurringBuy

    var id: Self { self }

    var pageIndex: Int {
        switch self {
        case .intro: return 0
        case .strategy: return 1
        case .marketUp: return 2
        case .marketDown: return 3
        case .final: return 4
        }
    }

    func lottiePageConfig() -> LottiePlayConfig {
        guard self != .intro else {
            return .pauseAtPosition(0.25)
        }
        let index = Double(pageIndex)
        let step = 1.0 / Double(RecurringBuyOnboardingScreens.allCases.count)
        let from = min(max(index * step, 0.0), 1.0)
        let to = min(max((index * step) + step, 0.0), 1.0)
        return .playProgress(from: from, to: to)
    }

    var titles: (main: String, highlighted: String) {
        switch self {
        case .intro:
            return (L10n.Onboarding.Pages.first, L10n.Onboarding.Pages.firstHighlight)
        case .strategy:
            return (L10n.Onboarding.Pages.second, L10n.Onboarding.Pages.secondHighlight)
        case .marketUp:
            return (L10n.Onboarding.Pages.third, L10n.Onboarding.Pages.thirdHighlight)
        case .marketDown:
            return (L10n.Onboarding.Pages.fourth, L10n.Onboarding.Pages.fourthHighlight)
        case .final:
            return (L10n.Onboarding.Pages.fifth, L10n.Onboarding.Pages.fifthHighlight)
        }
    }

    var footnote: String? {
        guard self == .final else {
            return nil
        }
        return L10n.Onboarding.Pages.fifthFootnote
    }

    var learnMoreLink: String? {
        guard self == .final else {
            return nil
        }
        return "https://support.blockchain.com/hc/en-us/articles/4517680403220"
    }
}

struct RecurringBuyOnboardingView: View {
    private typealias L10n = LocalizationConstants.Coin.RecurringBuy

    @BlockchainApp var app
    @Environment(\.scheduler) var scheduler

    let asset: String

    private let pages: [RecurringBuyOnboardingScreens] = RecurringBuyOnboardingScreens.allCases
    @State private var currentPage: RecurringBuyOnboardingScreens = .intro

    var body: some View {
        ZStack(alignment: .top) {
            ZStack(alignment: .top) {
                LottieView(
                    json: "pricechart".data(in: .componentLibrary),
                    loopMode: .playOnce,
                    playConfig: currentPage.lottiePageConfig()
                )
                .opacity(currentPage == .intro ? 0.2 : 1.0)
                .frame(height: 140)
                .padding(.top, 80)
                ZStack {
                    pagesContent
                    buttonsSection
                        .padding(.bottom, Spacing.padding6)
                }
            }
            header
        }
        .padding(.top, Spacing.padding2)
        .background(
            Color.semantic.light.ignoresSafeArea()
        )
    }

    @ViewBuilder
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: Spacing.textSpacing) {
                Text(L10n.Onboarding.title)
                    .typography(.body2)
                    .foregroundColor(.semantic.title)
                Text(L10n.Onboarding.subtitle)
                    .typography(.paragraph1)
                    .foregroundColor(.semantic.text)
                    .opacity(currentPage == .intro ? 1.0 : 0.0)
            }
            Spacer()
            Button {
                $app.post(event: blockchain.ux.asset.recurring.buy.onboarding.article.plain.navigation.bar.button.close.tap)
            } label: {
                Icon.closeCirclev3
                    .frame(width: 24, height: 24)
            }
        }
        .padding([.leading, .trailing], Spacing.padding2)
    }

    @ViewBuilder
    private var pagesContent: some View {
        TabView(
            selection: $currentPage.animation()
        ) {
            ForEach(pages) { page in
                page.makeView(app: app, assetId: asset)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }

    @ViewBuilder
    private var buttonsSection: some View {
        VStack(spacing: .zero) {
            Spacer()
            PageControl(
                controls: pages,
                selection: $currentPage.animation()
            )
            PrimaryButton(
                title: L10n.Onboarding.buttonTitle,
                action: {
                    Task { @MainActor [app] in
                        app.post(event: blockchain.ux.asset[asset].recurring.buy.onboarding.article.plain.navigation.bar.button.close.tap)
                        try await scheduler.sleep(for: .seconds(0.3))
                        app.post(event: blockchain.ux.asset[asset].buy)
                        try await scheduler.sleep(for: .seconds(0.3))
                        app.post(value: true, of: blockchain.ux.transaction.action.show.recurring.buy)
                    }
                }
            )
            .cornerRadius(Spacing.padding4)
        }
        .padding(.horizontal, Spacing.padding3)
    }
}

extension RecurringBuyOnboardingScreens {

    @ViewBuilder
    func makeView(app: AppProtocol, assetId: String) -> some View {
        VStack(alignment: .center, spacing: Spacing.padding3) {
            Group {
                Text(titles.main)
                    .typography(.title3)
                    .foregroundColor(.semantic.title)
                +
                Text(titles.highlighted)
                    .typography(.title3)
                    .foregroundColor(.semantic.primary)
            }
            .lineSpacing(5)
            .multilineTextAlignment(.center)
            if let footnote {
                VStack(spacing: Spacing.textSpacing) {
                    Text(footnote)
                        .typography(.caption1)
                        .foregroundColor(.semantic.body)
                        .multilineTextAlignment(.center)
                    if let learnMoreLink, let url = URL(string: learnMoreLink) {
                        Button {
                            app.post(event: blockchain.ux.asset[assetId].recurring.buy.onboarding.entry.paragraph.button.minimal.event.tap)
                        } label: {
                            Text(L10n.Onboarding.Pages.learnMore)
                                .typography(.caption1)
                                .foregroundColor(.semantic.primary)
                        }
                        .batch {
                            set(
                                blockchain.ux.asset[assetId].recurring.buy.onboarding.entry.paragraph.button.minimal.event.tap.then.launch.url,
                                to: url
                            )
                        }
                    }
                }
            }
        }
        .padding([.leading, .trailing], Spacing.padding4)
    }
}
