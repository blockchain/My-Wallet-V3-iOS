// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxRelay
import ToolKit

extension DependencyContainer {

    // MARK: - Today Extension Module

    static var today = module {

        factory { AnalyticsServiceMock() as AnalyticsEventRecording }

        factory { UIDevice.current as DeviceInfo }

        single { DataProvider() }

        factory { () -> HistoricalFiatPriceProviding in
            let dataProvider: DataProvider = DIKit.resolve()
            return dataProvider.historicalPrices as HistoricalFiatPriceProviding
        }

        factory { () -> ExchangeProviding in
            let dataProvider: DataProvider = DIKit.resolve()
            return dataProvider.exchange as ExchangeProviding
        }
    }
}

extension UIDevice: DeviceInfo {
    public var uuidString: String {
        UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
}

final class AnalyticsServiceMock: AnalyticsEventRecorderAPI {
    func record(events: [AnalyticsEvent]) {
        // NOOP
    }

    let recordRelay = PublishRelay<AnalyticsEvent>()

    func record(event: AnalyticsEvent) {
        // NOOP
    }
}
