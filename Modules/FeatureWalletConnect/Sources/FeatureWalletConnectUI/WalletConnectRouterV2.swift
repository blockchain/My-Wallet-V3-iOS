// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import EthereumKit
import FeatureWalletConnectDomain
import Foundation
import MoneyKit
import PlatformUIKit
import SwiftUI
import UIKit
import Web3Wallet

final class WalletConnectRouterV2 {

    private var bag: Set<AnyCancellable> = []

    private let analyticsEventRecorder: AnalyticsEventRecorderAPI
    private let service: WalletConnectServiceV2API

    @LazyInject private var tabSwapping: TabSwapping

    init(
        analyticsEventRecorder: AnalyticsEventRecorderAPI,
        service: WalletConnectServiceV2API
    ) {
        self.analyticsEventRecorder = analyticsEventRecorder
        self.service = service

    }
}
