// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension EnvironmentValues {
    public var isSmallDevice: Bool {
        get { self[IsSmallDeviceEnvironmentValue.self] }
        set { self[IsSmallDeviceEnvironmentValue.self] = newValue }
    }
}

struct IsSmallDeviceEnvironmentValue: EnvironmentKey {
    static var defaultValue = false
}

extension View {

    @warn_unqualified_access
    @ViewBuilder
    public func isSmallDevice(_ value: Bool) -> some View {
        environment(\.isSmallDevice, value)
    }
}
