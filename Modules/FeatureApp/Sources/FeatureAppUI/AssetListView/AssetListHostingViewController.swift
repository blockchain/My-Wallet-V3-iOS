//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Combine
import ComposableArchitecture
import DIKit
import FeatureNFTDomain
import FeatureNFTUI
import ToolKit
import UIComponentsKit
import UIKit

public final class AssetListHostingViewController: UIViewController {

    private let assetProviderService: FeatureNFTDomain.AssetProviderServiceAPI

    public init(
        assetProviderService: FeatureNFTDomain.AssetProviderServiceAPI = resolve()
    ) {
        self.assetProviderService = assetProviderService
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        embed(
            AssetListView(
                store: .init(
                    initialState: .empty,
                    reducer: AssetListReducer(
                        assetProviderService: assetProviderService as! AssetProviderService
                    )
                )
            )
        )
    }
}
