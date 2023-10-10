// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureInterestDomain
import Localization
import PlatformKit
import PlatformUIKit
import SwiftUI
import ToolKit
import UIComponentsKit

struct InterestAccountDetailsRowItemView: View {

    private typealias LocalizationId = LocalizationConstants.Interest.Screen.Overview

    let store: Store<InterestAccountOverviewRowItem, InterestAccountDetailsRowAction>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 4.0) {
                Text(viewStore.title)
                    .typography(.body2)
                Text(viewStore.description)
                    .typography(.paragraph1)
            }
            .padding(.init(top: 8.0, leading: 0.0, bottom: 8.0, trailing: 0.0))
        }
    }
}
