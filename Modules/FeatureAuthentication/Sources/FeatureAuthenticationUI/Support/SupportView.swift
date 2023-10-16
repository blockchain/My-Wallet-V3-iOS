// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureAuthenticationDomain
import Localization
import SwiftUI
import UIComponentsKit

struct SupportView: View {

    private typealias LocalizationIds = LocalizationConstants.Authentication.Support

    private let store: Store<SupportViewState, SupportViewAction>

    init(
        store: Store<SupportViewState, SupportViewAction>
    ) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ActionableView(buttons: [
                .init(
                    title: LocalizationIds.contactUs,
                    action: {
                        viewStore.send(.openURL(.contactUs))
                    },
                    style: .secondary
                ),
                .init(
                    title: LocalizationIds.viewFAQ,
                    action: {
                        viewStore.send(.openURL(.viewFAQ))
                    },
                    style: .secondary
                )
            ], content: {
                VStack(alignment: .leading, spacing: 10.0) {
                    Text(LocalizationIds.title)
                        .typography(.title3)
                    Text(LocalizationIds.description)
                        .typography(.paragraph1)
                }
                .padding(.init(top: 32.0, leading: 16.0, bottom: 16.0, trailing: 32.0))
            })
            .fixedSize(horizontal: false, vertical: true)
            .onAppear {
                viewStore.send(.loadAppStoreVersionInformation)
            }
        }
    }
}
