// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import DIKit
import ErrorsUI
import Localization
import SwiftUI
import UIComponentsKit

struct SuccessfullyVerifiedView: View {
    private typealias LocalizedString = LocalizationConstants.SuccessfullyVerified

    @ObservedObject private var viewStore: ViewStore<SuccessfullyVerified.State, SuccessfullyVerified.Action>

    init(store: StoreOf<SuccessfullyVerified>) {
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 20) {
                        if let image = UIImage(
                            named: "AccountApproved",
                            in: .featureProveUI,
                            compatibleWith: nil
                        ) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 77.0, height: 77.0)
                        }
                        VStack(spacing: 5) {
                            Text(LocalizedString.Body.title)
                                .typography(.title3)
                            Text(LocalizedString.Body.subtitle)
                                .typography(.body1)
                        }
                    }
                    .padding()
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.semantic.title)
                }
                .frame(width: geometry.size.width)
                .frame(height: geometry.size.height)
            }
        }
        .primaryNavigation(
            title: viewStore.title,
            trailing: {
                IconButton(icon: .navigationCloseButton()) {
                    viewStore.send(.onClose)
                }
                .frame(width: 24.pt, height: 24.pt)
            }
        )
        .hideBackButtonTitle()
        .navigationBarBackButtonHidden()
        .onAppear {
            viewStore.send(.onAppear)
        }

        PrimaryButton(
            title: LocalizedString.Buttons.finishTitle
        ) {
            viewStore.send(.onFinish)
        }
        .frame(alignment: .bottom)
        .padding([.horizontal, .bottom])
    }
}

struct SuccessfullyVerifiedView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            SuccessfullyVerifiedView(store: .init(
                initialState: .init(),
                reducer: SuccessfullyVerified.preview()
            ))
        }
    }
}
