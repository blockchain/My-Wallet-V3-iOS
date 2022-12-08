// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import Collections
import Combine
import ComposableArchitecture
import DIKit

// TODO: Move this to a better "globally" available place
enum AppProtocolDependencyKey: DependencyKey {
    static var liveValue: AppProtocol = resolve()
    static var previewValue: AppProtocol = App.preview
    static var testValue: Value = App.test
}

extension DependencyValues {
    var app: AppProtocol {
      get { self[AppProtocolDependencyKey.self] }
      set { self[AppProtocolDependencyKey.self] = newValue }
    }
}
