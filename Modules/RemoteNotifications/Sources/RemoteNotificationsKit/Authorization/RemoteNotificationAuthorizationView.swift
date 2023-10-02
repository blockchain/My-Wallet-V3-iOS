// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Localization
import SwiftUI

public struct RemoteNotificationAuthorizationView: View {

    @BlockchainApp var app

    private typealias L10n = LocalizationConstants.Notifications.Authorization
    private var onEnableTap: (() -> Void)?
    private var onDisableTap: (() -> Void)?

    public init() {}

    public var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: .zero) {
                VStack(spacing: Spacing.padding1) {
                    Text(L10n.title)
                        .typography(.body2)
                        .foregroundColor(.semantic.title)
                        .padding(.horizontal, 26)
                        .padding(.top, 21)
                    Text(L10n.message)
                        .typography(.caption1)
                        .foregroundColor(.semantic.title)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 26)
                    Rectangle()
                        .fill(Color.semantic.light)
                        .frame(width: 270, height: 1)
                        .padding(.top, Spacing.padding1)
                }
                HStack(spacing: .zero) {
                    Button {
                        $app.post(event: blockchain.ux.onboarding.notification.authorization.reject.paragraph.button.primary.tap)
                    } label: {
                        Text(L10n.dontAllow)
                            .typography(.body2)
                            .foregroundColor(.semantic.primary)
                    }
                    .frame(width: 135)
                    Rectangle()
                        .fill(Color.semantic.light)
                        .frame(width: 1, height: 48)
                    ZStack {
                        Button {
                            $app.post(event: blockchain.ux.onboarding.notification.authorization.accept.paragraph.button.primary.tap)
                        } label: {
                            Text(L10n.allow)
                                .typography(.body2)
                                .foregroundColor(.semantic.primary)
                        }
                        .frame(width: 135)
                        Circle()
                            .strokeBorder(Color.semantic.primary, lineWidth: 1)
                            .frame(width: 64)
                            .scaleEffect(1.4)
                            .allowsHitTesting(false)
                    }
                    .frame(height: 48)
                }
            }
            .frame(width: 270)
            .background(
                RoundedRectangle(
                    cornerRadius: Spacing.padding2
                )
                .fill(Color.semantic.background)
            )
            Icon.notification
                .frame(width: 56, height: 56)
                .offset(y: -38)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.semantic.light.ignoresSafeArea())
        .batch {
            set(blockchain.ux.onboarding.notification.authorization.accept.paragraph.button.primary.tap.then.close, to: true)
            set(blockchain.ux.onboarding.notification.authorization.reject.paragraph.button.primary.tap.then.close, to: true)
        }
    }
}

struct RemoteNotificationAuthorization_Previews: PreviewProvider {
    static var previews: some View {
        RemoteNotificationAuthorizationView()
            .app(App.preview)
    }
}
