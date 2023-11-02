// Copyright © Blockchain Luxembourg S.A. All rights reserved.

enum LoadingState<Content, Failure> {
    case idle
    case loading
    case success(Content)
    case failure(Failure)

    var isLoading: Bool {
        let isLoading: Bool = switch self {
        case .loading:
            true
        default:
            false
        }
        return isLoading
    }
}

extension LoadingState: Equatable where Content: Equatable, Failure: Equatable {}
