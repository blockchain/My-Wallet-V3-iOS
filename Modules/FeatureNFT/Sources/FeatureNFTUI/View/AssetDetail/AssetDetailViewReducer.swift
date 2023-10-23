import Combine
import ComposableArchitecture
import FeatureNFTDomain

struct AssetDetailReducer: Reducer {

    typealias State = AssetDetailViewState
    typealias Action = AssetDetailViewAction

    var body: some Reducer<State, Action> {
        Reduce { _, action in
            switch action {
            case .viewOnWebTapped:
                return .none
            }
        }
    }
}
