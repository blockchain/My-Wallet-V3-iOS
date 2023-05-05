//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import ComposableArchitecture
import DIKit
import FeatureNFTDomain
import FeatureNFTUI
import SwiftUI
import ToolKit
import UIKit

public struct AssetListViewController: UIViewControllerRepresentable {

    let store: Store<AssetListViewState, AssetListViewAction>

    public init(
        assetProviderService: FeatureNFTDomain.AssetProviderServiceAPI = resolve()
    ) {
        self.store = .init(
            initialState: .empty,
            reducer: assetListReducer,
            environment: .init(
                assetProviderService: assetProviderService
            )
        )
    }

    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    public func makeUIViewController(context: Context) -> some UIViewController {
        UIHostingController(rootView: AssetListView(store: store))
    }
}
