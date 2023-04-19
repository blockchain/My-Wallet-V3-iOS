// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI

struct LivePricesList: View {

    let store: Store<TourState, TourAction>

    var body: some View {
        GeometryReader { reader in
            ScrollView {
                LazyVStack {
                    ForEachStore(
                        store.scope(
                            state: \.items,
                            action: TourAction.price(id:action:)
                        ),
                        content: PriceView.init(store:)
                    )
                    Color.clear.padding(.bottom, 180) // contentInset
                }
                .anchorPreference(key: OffsetKey.self, value: .top) {
                    reader[$0].y
                }
                .background(Color.clear)
                .padding(.horizontal)
            }
        }
    }
}
