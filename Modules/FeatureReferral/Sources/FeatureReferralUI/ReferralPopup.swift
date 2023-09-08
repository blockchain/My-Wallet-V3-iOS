// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import SwiftUI
import UIComponentsKit

public struct ReferralPopup: View {
    let store: Store<ReferFriendState, ReferFriendAction>
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewStore: ViewStore<ReferFriendState, ReferFriendAction>

    public init(store: Store<ReferFriendState, ReferFriendAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
        ZStack {
            VStack {
                ZStack {
                    imageSection
                    closeButton
                }
                labelsSection
                buttonsSection
                    .padding(.top, 65)
                    .padding(.bottom, 20)
            }
            .frame(maxHeight: .infinity)
        }
        .background(Color.semantic.primary)
        .onAppear(perform: {
            viewStore.send(.onAppear)
        })
        .sheet(
            isPresented: viewStore
                .binding(\.$isShowReferralViewPresented),
            content: {
                ReferFriendView(store: store)
            }
        )
    }

    private var imageSection: some View {
        Image("image_referral_popup", bundle: .module)
            .resizable()
            .frame(width: 331, height: 331)
    }

    var labelsSection: some View {
        VStack(spacing: 30, content: {
            Text(viewStore.referralInfo.rewardTitle)
                .typography(.title1)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .padding(.horizontal, Spacing.padding3)

            Text(viewStore.referralInfo.rewardSubtitle)
                .typography(.paragraph1)
                .foregroundColor(.white)
        })
    }

    var closeButton: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image("cancel_icon", bundle: Bundle.UIComponents)
                        .renderingMode(.template)
                        .foregroundColor(.white)
                }
            }
            .padding(.top, Spacing.padding3)
            .padding(.bottom, 400)
            .padding(.trailing, Spacing.padding3)
        }
    }

    private var buttonsSection: some View {
        VStack(spacing: 2, content: {
            PrimaryWhiteButton(title: "Share") {
                viewStore.send(.onShowRefferalTapped)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Spacing.padding3)
            .padding(.bottom, Spacing.padding5)

            Button("Skip") {
                presentationMode.wrappedValue.dismiss()
            }
            .foregroundColor(.white)
        })
    }
}
