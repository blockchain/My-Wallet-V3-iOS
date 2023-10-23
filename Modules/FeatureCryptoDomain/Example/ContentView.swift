// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
@testable import FeatureCryptoDomainData
import FeatureCryptoDomainDomain
@testable import FeatureCryptoDomainMock
@testable import FeatureCryptoDomainUI
import SwiftUI
import ToolKit

struct ContentView: View {

    @State var claimFlowShown = false

    var body: some View {
        VStack {
            Button("Let's claim a domain!") {
                claimFlowShown.toggle()
            }
        }
        .sheet(isPresented: $claimFlowShown) {
            ClaimIntroductionView(
                store: Store(
                    initialState: .init(),
                    reducer: {
                        ClaimIntroduction(
                            analyticsRecorder: _AnalyticsEventRecorderAPI(),
                            externalAppOpener: _ExternalAppOpener(),
                            searchDomainRepository: SearchDomainRepository(
                                apiClient: SearchDomainClient.mock
                            ),
                            orderDomainRepository: OrderDomainRepository(
                                apiClient: OrderDomainClient.mock
                            ),
                            userInfoProvider: {
                                .just(
                                    OrderDomainUserInfo(
                                        nabuUserId: "mockUserId",
                                        nabuUserName: "Firstname",
                                        resolutionRecords: []
                                    )
                                )
                            }
                        )
                    }
                )
            )
        }
    }
}

private struct _ExternalAppOpener: ExternalAppOpener {
    func openMailApp(completionHandler: @escaping (Bool) -> Void) {
        print("openMailApp:")
    }

    func openSettingsApp(completionHandler: @escaping (Bool) -> Void) {
        print("openSettingsApp:")
    }

    func open(_ url: URL, completionHandler: @escaping (Bool) -> Void) {
        print("open: \(url)")
    }
}

private class _AnalyticsEventRecorderAPI: AnalyticsEventRecorderAPI {
    func record(event: AnalyticsKit.AnalyticsEvent) {
        print("record: \(event)")
    }
}
