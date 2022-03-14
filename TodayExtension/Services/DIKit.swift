// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import NetworkKit
import PlatformDataKit
import PlatformKit
import PlatformUIKit
import ToolKit
import UIKit

extension DependencyContainer {

    // MARK: - Today Extension Module

    static var today = module {

        factory { AnalyticsServiceMock() as AnalyticsEventRecorderAPI }

        factory { UIDevice.current as DeviceInfo }

        factory { FiatCurrencyService() as FiatCurrencyServiceAPI }

        factory { ErrorRecorderMock() as ErrorRecording }
    }

    static var setupDependencies: Void = DependencyContainer.defined(by: modules {
        DependencyContainer.today
        DependencyContainer.toolKit
        DependencyContainer.networkKit
        DependencyContainer.platformDataKit
        DependencyContainer.platformKit
        DependencyContainer.platformUIKit
    })
}
