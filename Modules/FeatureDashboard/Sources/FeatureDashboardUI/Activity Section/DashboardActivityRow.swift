// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainNamespace
import ComposableArchitecture
import FeatureDashboardDomain
import Foundation
import SwiftUI
import UnifiedActivityDomain

public struct DashboardActivityRow: ReducerProtocol {
    public let app: AppProtocol
    public init(
        app: AppProtocol
    ) {
        self.app = app
    }

    public enum Action: Equatable {
        case onActivityTapped
        case context(Tag.Context)
    }

    public struct State: Equatable, Identifiable {
        public var id: String {
            "\(activity.network)/\(activity.id)"
        }

        var activity: ActivityEntry
        var isLastRow: Bool
        var context: Tag.Context?

        public init(
            isLastRow: Bool,
            activity: ActivityEntry
        ) {
            self.activity = activity
            self.isLastRow = isLastRow
        }
    }

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .context(let context):
                state.context = context
                return .none

            case .onActivityTapped:
                return .fireAndForget { [activity = state.activity, context = state.context] in
                    if let context {
                        app.post(event: blockchain.ux.activity.detail[activity.id].entry.paragraph.row.tap, context: context + [
                            blockchain.ux.activity.detail.model: activity
                        ])
                    }
                }
            }
        }
    }
}
