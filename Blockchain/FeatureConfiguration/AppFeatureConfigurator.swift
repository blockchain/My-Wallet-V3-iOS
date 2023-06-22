// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Combine
import RxSwift
import RxToolKit
import ToolKit

enum RemoteConfigConstants {
    static let notificationKey: String = "CONFIG_STATE"
    static let notificationValue: String = "STALE"
}

final class AppFeatureConfigurator {

    // MARK: Private Properties

    private let app: AppProtocol

    // MARK: Init

    init(app: AppProtocol) {
        self.app = app
    }
}
