// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI
import UIComponentsKit

struct LoadingView: View {

    var title: String?
    var subtitle: String?
    @Binding var buttonTitle: String?
    @Binding var buttonDisabled: Bool
    var buttonAction: (() -> Void)?

    init(
        title: String? = nil,
        subtitle: String? = nil,
        buttonTitle: Binding<String?> = .constant(nil),
        buttonDisabled: Binding<Bool> = .constant(false),
        buttonAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        _buttonTitle = buttonTitle
        _buttonDisabled = buttonDisabled
        self.buttonAction = buttonAction
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .center) {
                    ProgressView(value: 0.25)
                        .progressViewStyle(
                            IndeterminateProgressStyle()
                        )
                        .frame(width: 45, height: 45)
                        .padding(.bottom, 35.pt)
                    if let title {
                        Text(title)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .typography(.title3)
                            .foregroundTexture(.semantic.title)
                            .padding(.bottom, Spacing.padding1)
                    }
                    if let subtitle {
                        Text(subtitle)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .typography(.body1)
                            .foregroundTexture(.semantic.text)
                            .padding(.bottom, Spacing.padding3)
                    }
                    if let buttonTitle {
                        HStack {
                            SmallMinimalButton(
                                title: buttonTitle,
                                action: { buttonAction?() }
                            )
                            .disabled(buttonDisabled)
                        }
                    }
                }
                .padding()
                .frame(width: geometry.size.width)
                .frame(height: geometry.size.height)
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            LoadingView(
                title: "Title",
                subtitle: "Subtitle",
                buttonTitle: .constant("Button"),
                buttonDisabled: .constant(false)
            )
        }
    }
}
