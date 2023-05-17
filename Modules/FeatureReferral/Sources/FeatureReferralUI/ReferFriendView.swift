// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureReferralDomain
import FeatureReferralMocks
import Localization
import SwiftUI
import UIComponentsKit

typealias LocalizedStrings = LocalizationConstants.Referrals.ReferralScreen

public struct ReferFriendView: View {

    let store: Store<ReferFriendState, ReferFriendAction>
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewStore: ViewStore<ReferFriendState, ReferFriendAction>

    public init(store: Store<ReferFriendState, ReferFriendAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var referral: Referral { viewStore.referralInfo }

    public var body: some View {
        ZStack(alignment: .top) {
            HStack {
                Spacer()
                IconButton(icon: .close.circle()) {
                    presentationMode.wrappedValue.dismiss()
                }
                .frame(width: 24.pt, height: 24.pt)
                .padding()
            }
            .zIndex(1)
            VStack {
                ScrollView {
                    icon
                    inviteFriends
                    referralCode
                    Spacer()
                    steps
                }
                shareButton
            }
            .padding(.top)
            .zIndex(0)
        }
        .backgroundTexture(
            referral.promotion?.style?.background
        )
        .foregroundTexture(
            referral.promotion?.style?.foreground ?? referral.promotion?.style?.background != nil
            ? Color.semantic.light.texture
            : Color.semantic.title.texture
        )
        .ignoresSafeArea(.all)
        .onAppear {
            viewStore.send(.onAppear)
        }
        .sheet(isPresented: viewStore.binding(\.$isShareModalPresented)) {
            ActivityViewController(
                itemsToShare: [
                    ActivityItemSource(
                        title: LocalizedStrings.shareTitle,
                        text: LocalizedStrings.shareMessage(referral.code)
                    )
                ]
            )
        }
    }
}

extension ReferFriendView {
    @ViewBuilder private var icon: some View {
        if let icon = referral.promotion?.icon {
            AsyncMedia(url: icon.url)
                .frame(width: 80, height: 80)
                .foregroundColor(.semantic.primary)
        }
    }

    private var inviteFriends: some View {
        VStack(alignment: .center) {
            Text(rich: referral.promotion?.title ?? referral.rewardTitle)
                .typography(.title2)
                .foregroundColor(.semantic.title)
            Color.clear
                .frame(height: 18.pt)
            Text(rich: referral.promotion?.message ?? referral.rewardSubtitle)
                .typography(.paragraph1)
                .foregroundColor(.semantic.title)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, Spacing.padding3)
        .padding(.top, 12)
    }

    private var referralCode: some View {
        VStack {
            Text(LocalizedStrings.referralCodeLabel)
                .typography(.paragraph1)
                .apply { text in
                    if (referral.promotion?.style).isNil {
                        text.foregroundColor(Color.semantic.muted)
                    } else if let texture = referral.promotion?.style?.foreground {
                        text.foregroundTexture(texture)
                    } else {
                        text.foregroundColor(Color.semantic.light)
                    }
                }

            VStack(alignment: .center, spacing: Spacing.padding2) {
                Text(referral.code)
                    .typography(.title2)
                    .foregroundColor(.semantic.title)
                    .fontWeight(.medium)
                    .kerning(15)
                    .padding(.top, Spacing.padding3)
                let label = viewStore.state.codeIsCopied
                ? LocalizedStrings.copiedLabel
                : LocalizedStrings.copyLabel
                Button(label) {
                    viewStore.send(.onCopyTapped)
                }
                .typography(.paragraph2)
                .padding(.bottom, Spacing.padding3)
                .foregroundColor(Color.semantic.primary)
            }
            .frame(maxWidth: .infinity)
            .apply { view in
                if (referral.promotion?.style).isNil {
                    view.background(Color("color_code_background", bundle: .module))
                } else {
                    view.background(Color.semantic.ultraLight)
                }
            }
        }
        .padding([.top, .horizontal], Spacing.padding3)
    }

    private var steps: some View {
        VStack(alignment: .leading) {
            Text(LocalizedStrings.stepsTitleLabel)
                .typography(.paragraph1)
                .apply { text in
                    if (referral.promotion?.style).isNil {
                        text.foregroundColor(Color.semantic.muted)
                    } else if let texture = referral.promotion?.style?.foreground {
                        text.foregroundTexture(texture)
                    } else {
                        text.foregroundColor(Color.semantic.muted)
                    }
                }
            VStack(alignment: .leading, spacing: 0) {
                ForEach(referral.criteria.indexed(), id: \.element.id) { index, step in
                    HStack {
                        numberView(with: index + 1)
                        Text(step.text)
                            .typography(.paragraph1)
                            .apply { text in
                                if (referral.promotion?.style).isNil {
                                    text.foregroundColor(Color.semantic.title)
                                } else if let texture = referral.promotion?.style?.foreground {
                                    text.foregroundTexture(texture)
                                } else {
                                    text.foregroundColor(Color.semantic.title)
                                }
                            }
                    }
                    if index != referral.criteria.count - 1 {
                        Rectangle()
                            .fill(Color.semantic.primaryUltraLight)
                            .frame(width: 2, height: 6)
                            .padding(.leading, 11.5)
                            .padding(.vertical, 2)
                    }
                }
            }
        }
        .padding(.top, Spacing.padding5)
    }

    private var shareButton: some View {
        PrimaryButton(title: LocalizedStrings.shareButton) {
            viewStore.send(.onShareTapped)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Spacing.padding3)
        .padding(.bottom, Spacing.padding4)
    }

    @ViewBuilder func numberView(with number: Int) -> some View {
        Text("\(number)")
            .typography(.body2)
            .frame(width: 24, height: 24)
            .foregroundColor(.semantic.primary)
            .background(Color.semantic.primaryUltraLight)
            .clipShape(Circle())
    }
}

struct ActivityViewController: UIViewControllerRepresentable {

    var itemsToShare: [Any]
    var servicesToShareItem: [UIActivity]?

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<ActivityViewController>
    ) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: itemsToShare,
            applicationActivities: servicesToShareItem
        )
        return controller
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: UIViewControllerRepresentableContext<ActivityViewController>
    ) {}
}

class ActivityItemSource: NSObject, UIActivityItemSource {
    var title: String
    var text: String

    init(title: String, text: String) {
        self.title = title
        self.text = text
        super.init()
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        text
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        text
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        subjectForActivityType activityType: UIActivity.ActivityType?
    ) -> String {
        if activityType == .mail {
            return title
        }
        return ""
    }
}
