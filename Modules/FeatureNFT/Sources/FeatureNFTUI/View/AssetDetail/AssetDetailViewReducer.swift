import Combine
import ComposableArchitecture
import FeatureNFTDomain

struct AssetDetailReducer: ReducerProtocol {
    
    typealias State = AssetDetailViewState
    typealias Action = AssetDetailViewAction
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .viewOnWebTapped:
                return .none
            }
        }
    }
}
