// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import SwiftUI
import UIComponentsKit

struct PriceView: View {

    let store: Store<Price, PriceAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack(spacing: 16) {
                viewStore.currency
                    .logo(size: 32.pt, showNetworkLogo: true)
                VStack(spacing: 2) {
                    HStack {
                        Text(viewStore.title)
                            .typography(.body1)
                            .foregroundColor(.semantic.title)
                        Spacer()
                        Text(viewStore.value.value ?? "")
                            .typography(.body1)
                            .foregroundColor(.semantic.body)
                            .shimmer(enabled: viewStore.value.isLoading)
                    }
                    HStack {
                        Text(viewStore.abbreviation)
                            .typography(.body1)
                            .foregroundColor(.semantic.title)
                            .textStyle(.subheading)
                        Spacer()
                        Text(viewStore.formattedDelta)
                            .foregroundColor(color(viewStore.deltaPercentage.value))
                            .typography(.body1)
                            .shimmer(enabled: viewStore.deltaPercentage.isLoading)
                    }
                }
            }
            .padding([.top, .bottom], 10)
            .padding(.horizontal)
            .onAppear {
                viewStore.send(.currencyDidAppear)
            }
            .onDisappear {
                viewStore.send(.currencyDidDisappear)
            }
        }
    }

    private func color(_ value: Double?) -> Color {
        let delta: Decimal = Decimal(value ?? 0)
        if delta.isSignMinus {
            return .semantic.pink
        } else if delta.isZero {
            return .semantic.body
        } else {
            return .semantic.success
        }
    }
}
