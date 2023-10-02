// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import ComposableNavigation
import FeatureAuthenticationDomain
import ToolKit

public enum SupportViewAction: Equatable {
    public enum URLContent {
        case contactUs
        case viewFAQ
    }

    case loadAppStoreVersionInformation
    case failedToRetrieveAppStoreInfo
    case appStoreVersionInformationReceived(AppStoreApplicationInfo)
    case openURL(URLContent)
}

struct SupportViewState: Equatable {
    let applicationVersion: String
    let bundleIdentifier: String
    var appStoreVersion: String?
    var isApplicationUpdated: Bool

    init(
        applicationVersion: String,
        bundleIdentifier: String
    ) {
        self.applicationVersion = applicationVersion
        self.bundleIdentifier = bundleIdentifier
        self.appStoreVersion = nil
        self.isApplicationUpdated = true
    }
}

struct SupportViewReducer: ReducerProtocol {

    typealias State = SupportViewState
    typealias Action = SupportViewAction

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let appStoreInformationRepository: AppStoreInformationRepositoryAPI
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let externalAppOpener: ExternalAppOpener

    init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        appStoreInformationRepository: AppStoreInformationRepositoryAPI,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        externalAppOpener: ExternalAppOpener
    ) {
        self.mainQueue = mainQueue
        self.appStoreInformationRepository = appStoreInformationRepository
        self.analyticsRecorder = analyticsRecorder
        self.externalAppOpener = externalAppOpener
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadAppStoreVersionInformation:
                analyticsRecorder.record(event: .customerSupportClicked)
                return appStoreInformationRepository
                    .verifyTheCurrentAppVersionIsTheLatestVersion(
                        state.applicationVersion,
                        bundleId: "com.rainydayapps.Blockchain"
                    )
                    .receive(on: mainQueue)
                    .catchToEffect()
                    .map { result -> SupportViewAction in
                        guard let applicationInfo = result.success else {
                            return .failedToRetrieveAppStoreInfo
                        }
                        return .appStoreVersionInformationReceived(applicationInfo)
                    }
            case .appStoreVersionInformationReceived(let applicationInfo):
                state.isApplicationUpdated = applicationInfo.isApplicationUpToDate
                state.appStoreVersion = applicationInfo.version
                return .none
            case .failedToRetrieveAppStoreInfo:
                return .none
            case .openURL(let content):
                switch content {
                case .contactUs:
                    analyticsRecorder.record(event: .contactUsClicked)
                    externalAppOpener.open(URL(string: Constants.SupportURL.PIN.contactUs)!)
                case .viewFAQ:
                    analyticsRecorder.record(event: .viewFAQsClicked)
                    externalAppOpener.open(URL(string: Constants.SupportURL.PIN.viewFAQ)!)
                }
                return .none
            }
        }
    }
}
