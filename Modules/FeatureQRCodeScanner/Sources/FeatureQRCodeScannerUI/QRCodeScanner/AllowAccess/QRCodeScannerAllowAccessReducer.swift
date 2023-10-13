// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AVKit
import Combine
import ComposableArchitecture

enum AllowAccessAction: Equatable {
    case allowCameraAccess
    case dismiss
    case showCameraDeniedAlert
    case openWalletConnectUrl
    case onAppear
    case showsWalletConnectRow(Bool)
}

struct AllowAccessState: Equatable {
    static let walletConnectArticleUrl = "https://support.blockchain.com/hc/en-us/articles/4572777318548"

    /// Hides the action button
    let informationalOnly: Bool
    var showWalletConnectRow: Bool
}

struct AllowAccessReducer: Reducer {

    typealias State = AllowAccessState
    typealias Action = AllowAccessAction

    let allowCameraAccess: () -> Void
    let cameraAccessDenied: () -> Bool
    let dismiss: () -> Void
    let showCameraDeniedAlert: () -> Void
    let showsWalletConnectRow: () -> AnyPublisher<Bool, Never>
    let openWalletConnectUrl: (String) -> Void

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .publisher {
                    showsWalletConnectRow()
                        .map(AllowAccessAction.showsWalletConnectRow)
                }
            case .showsWalletConnectRow(let display):
                state.showWalletConnectRow = display
                return .none
            case .allowCameraAccess:
                guard !cameraAccessDenied() else {
                    return .concatenate(
                        Effect.send(.dismiss),
                        Effect.send(.showCameraDeniedAlert)
                    )
                }
                allowCameraAccess()
                return Effect.send(.dismiss)
            case .showCameraDeniedAlert:
                showCameraDeniedAlert()
                return .none
            case .dismiss:
                dismiss()
                return .none
            case .openWalletConnectUrl:
                openWalletConnectUrl(
                    AllowAccessState.walletConnectArticleUrl
                )
                return .none
            }
        }
    }
}
