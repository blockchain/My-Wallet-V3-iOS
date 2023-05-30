// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if canImport(SwiftUI)
import DIKit
import SwiftUI

extension EnvironmentValues {

    public var coincore: CoincoreAPI {
        get { self[CoincoreAPIEnvironmentKey.self] }
        set { self[CoincoreAPIEnvironmentKey.self] = newValue }
    }
}

struct CoincoreAPIEnvironmentKey: EnvironmentKey {
    static let defaultValue: CoincoreAPI = DIKit.resolve()
}
#endif
