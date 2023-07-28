// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureInterestDomain
import Localization
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit
import UIComponentsKit

struct InterestAccountListItem: View {

    private typealias LocalizationId = LocalizationConstants.Interest.Screen.Overview

    let store: Store<InterestAccountDetails, InterestAccountListItemAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ActionableView(
                buttons: viewStore.actions.map { action in
                    .init(
                        title: viewStore.actionDisplayString,
                        action: {
                            viewStore.send(action)
                        },
                        enabled: viewStore.isEligible
                    )
                },
                content: {
                    VStack(alignment: .leading, spacing: 12.0) {
                        HStack {
                            badgeImageViewWithViewModel(viewStore.badgeImageViewModel)
                                .frame(width: 32, height: 32)
                            Text(viewStore.currency.name)
                                .textStyle(.title)
                                .foregroundColor(.semantic.title)
                        }
                        HStack {
                            Image.CircleIcon.infoIcon
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 14.0, height: 14.0)
                            Text(
                                String(
                                    format: LocalizationId.earnUpTo,
                                    "\(viewStore.rate.string(with: 1))%",
                                    viewStore.currency.displayCode
                                )
                            )
                            .textStyle(.body)
                            .foregroundColor(.semantic.text)
                        }
                    }
                    Spacer(minLength: 12.0)
                    Divider()
                        .background(Color.semantic.light)
                    Spacer(minLength: 12.0)
                    HStack {
                        VStack(alignment: .leading, spacing: 4.0) {
                            Text("\(viewStore.currency.displayCode) \(LocalizationId.balance)")
                                .textStyle(.body)
                                .foregroundColor(.semantic.text)
                            Text(viewStore.balance.displayString)
                                .textStyle(.heading)
                                .foregroundColor(.semantic.title)
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 4.0) {
                            Text(LocalizationId.totalEarned)
                                .textStyle(.body)
                                .foregroundColor(.semantic.text)
                            Text(viewStore.interestEarned.displayString)
                                .textStyle(.heading)
                                .foregroundColor(.semantic.title)
                        }
                    }
                    Spacer(minLength: 12.0)
                    if !viewStore.isEligible {
                        HStack {
                            Image.CircleIcon.infoIcon
                                .renderingMode(.template)
                                .foregroundColor(.badgeTextWarning)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 14.0, height: 14.0)
                            Text(viewStore.ineligibilityReason.displayString)
                                .typography(.body2)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.lightContentBackground)
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
            )
        }
    }

    private func badgeImageViewWithViewModel(_ viewModel: BadgeImageViewModel) -> some View {
        BadgeImageViewRepresentable(
            viewModel: viewModel,
            size: 32
        )
    }
}
