// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Localization
import SwiftUI

struct LivePricesHeader: View {

    @State private var circleIsVisible = true

    @Binding var offset: CGFloat

    private let titleHeight: CGFloat = 64
    private var clippedTitleHeight: CGFloat {
        let calculatedHeight = titleHeight + offset
        return calculatedHeight.clamped(to: 0...titleHeight)
    }

    var body: some View {
        VStack(spacing: .zero) {
            VStack {
                Text(LocalizationConstants.Tour.carouselPricesScreenTitle)
                    .typography(.title3)
                    .multilineTextAlignment(.center)
                    .frame(height: titleHeight)
            }
            .padding(.bottom, Spacing.padding2)
            .frame(width: 180.0, height: clippedTitleHeight)
            .clipped()

            HStack(alignment: .firstTextBaseline) {
                Circle()
                    .fill(Color.green)
                    .animation(nil)
                    .frame(width: 8, height: 8)
                    .opacity(circleIsVisible ? 1 : 0)
                    .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true))
                    .onAppear {
                        circleIsVisible.toggle()
                    }
                Text(LocalizationConstants.Tour.carouselPricesScreenLivePrices)
                    .typography(.body2)
                    .foregroundColor(.semantic.title)
            }
        }
    }
}
