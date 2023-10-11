// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import Errors
import FeatureFormDomain
import FeatureKYCDomain
import Foundation
import Localization
import PlatformKit
import ToolKit

private typealias LocalizedStrings = LocalizationConstants.NewKYC.Steps.IdentityVerification

struct IdentityVerificationReducer: Reducer {

    typealias State = IdentityVerificationState
    typealias Action = IdentityVerificationAction

    let onCompletion: () -> Void
    let supportedDocumentTypes: () -> AnyPublisher<[KYCDocumentType], NabuNetworkError>
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let mainQueue: AnySchedulerOf<DispatchQueue>

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .startVerification:
                onCompletion()
                return .none              

            case .fetchSupportedDocumentTypes:
                state.isLoading = true
                return .run { send in
                    do {
                        let result = try await supportedDocumentTypes()
                            .receive(on: mainQueue)
                            .await()
                        await send(.didReceiveSupportedDocumentTypesResult(.success(result)))
                    } catch {
                        await send(.didReceiveSupportedDocumentTypesResult(.failure(error as! NabuNetworkError)))
                    }
                }

            case .didReceiveSupportedDocumentTypesResult(let result):
                state.isLoading = false
                switch result {
                case .success(let documents):
                    state.documentTypes = documents
                        .sorted { $0.order < $1.order }
                case .failure(let error):
                    Logger.shared.error("\(error)")
                    analyticsRecorder.record(
                        event: ClientEvent.clientError(
                            id: error.ux?.id,
                            error: "KYC_SHOW_DOCUMENTS_TYPES_ERROR",
                            networkEndpoint: error.request?.url?.absoluteString ?? "",
                            networkErrorCode: "\(error.code)",
                            networkErrorDescription: error.description,
                            networkErrorId: nil,
                            networkErrorType: error.type.rawValue,
                            source: "NABU",
                            title: "KYC_SHOW_DOCUMENTS_TYPES"
                        )
                    )
                }
                return .none

            case .onViewAppear:
                return Effect.send(.fetchSupportedDocumentTypes)
            }
        }
    }
}

extension Store where State == IdentityVerificationState, Action == IdentityVerificationAction {

    static let emptyPreview = Store(
        initialState: IdentityVerificationState(),
        reducer: {
            IdentityVerificationReducer(
                onCompletion: {},
                supportedDocumentTypes: { .empty() },
                analyticsRecorder: NoOpAnalyticsRecorder(),
                mainQueue: .main
            )
        }
    )

    static let filledPreview = Store(
        initialState: IdentityVerificationState(),
        reducer: {
            IdentityVerificationReducer(
                onCompletion: {},
                supportedDocumentTypes: { .empty() },
                analyticsRecorder: NoOpAnalyticsRecorder(),
                mainQueue: .main
            )
        }
    )
}

extension KYCDocumentType {
    fileprivate var order: Int {
        switch self {
        case .passport:
            return 0
        case .nationalIdentityCard:
            return 1
        case .residencePermit:
            return 2
        case .driversLicense:
            return 3
        }
    }
}
