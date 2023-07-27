// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import FeatureCoinDomain
import Foundation
import Localization
import SwiftUI

public struct ComingSoonView: View {
    private typealias Localization = LocalizationConstants.Coin.Account.ComingSoon

    @BlockchainApp var app
    @Environment(\.context) var context

    let account: Account.Snapshot
    let assetLogoUrl: URL?
    let assetColor: Color
    let onClose: () -> Void

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(account.name)
                    .typography(.body2)
                    .foregroundColor(.semantic.title)
                Spacer()
                IconButton(icon: .navigationCloseButton(), action: onClose)
                    .frame(width: 24.pt, height: 24.pt)
            }
            .padding(.leading, Spacing.padding3)
            .padding(.trailing, Spacing.padding2)
            VStack {
                Spacer()
                VStack(spacing: Spacing.padding5) {
                    ZStack(alignment: .topTrailing) {
                        assetLogo()
                        lockIcon()
                            .offset(x: Spacing.padding2, y: -Spacing.padding2)
                    }
                    VStack(spacing: Spacing.padding2) {
                        Text(Localization.title)
                            .typography(.title3)
                            .foregroundColor(.semantic.title)
                        Text(Localization.subtitle.interpolating(account.name))
                            .multilineTextAlignment(.center)
                            .typography(.body1)
                            .foregroundColor(.semantic.text)
                        SmallMinimalButton(title: Localization.learnMore) {
                            let url = try? await app.get(blockchain.ux.asset.account.coming.soon.visit.learn.more.url) as URL
                            let fallback = try? await app.get(blockchain.app.configuration.asset.coming.soon.learn.more.url) as URL
                            app.post(
                                event: blockchain.ux.asset.account.coming.soon.visit.learn.more.then.launch.url[].ref(to: context),
                                context: [
                                    blockchain.ui.type.action.then.launch.url: url ?? fallback
                                ]
                            )
                        }
                    }
                    .padding([.leading, .trailing], Spacing.padding2)
                }
                Spacer()
                PrimaryButton(title: Localization.goToWebApp) {
                    let url = try? await app.get(blockchain.ux.asset.account.coming.soon.visit.web.app.url) as URL
                    let fallback = try? await app.get(blockchain.app.configuration.asset.coming.soon.visit.web.app.url) as URL
                    app.post(
                        event: blockchain.ux.asset.account.coming.soon.visit.web.app.then.launch.url[].ref(to: context),
                        context: [
                            blockchain.ui.type.action.then.launch.url: url ?? fallback
                        ]
                    )
                }
            }
            .padding(Spacing.padding2)
        }
        .padding(.top, Spacing.padding2)
    }

    @ViewBuilder func lockIcon() -> some View {
        Circle()
            .foregroundColor(.white)
            .frame(width: 40.pt, height: 40.pt)
            .overlay(
                Icon.lockClosed
                    .medium()
                    .color(.white)
                    .circle(backgroundColor: .semantic.primary)
                    .frame(width: 36.pt, height: 36.pt)
            )
    }

    @ViewBuilder func assetLogo() -> some View {
        if let url = assetLogoUrl {
            AsyncMedia(
                url: url,
                content: { media in
                    media.cornerRadius(12)
                },
                placeholder: {
                    Color.semantic.muted
                        .opacity(0.3)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(.circular)
                        )
                        .clipShape(Circle())
                }
            )
            .resizingMode(.aspectFit)
            .frame(width: 72.pt, height: 72.pt)
        }
    }
}

struct ComingSoonPreviewProvider: PreviewProvider {
    static var previews: some View {
        ComingSoonView(
            account: .preview.trading,
            assetLogoUrl: nil,
            assetColor: .primary,
            onClose: {}
        )
    }
}
