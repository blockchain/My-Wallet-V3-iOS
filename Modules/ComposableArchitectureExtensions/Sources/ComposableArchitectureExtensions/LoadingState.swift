// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// This enum embeds a loading state. Can be used to UI
/// gestures / just for interaction
public enum LoadingState<Content> {

    /// A `loading` state. Typically intial loading
    case loading

    /// A `loaded` state that has content to be shown next
    case loaded(next: Content)

    /// Returns the content if not `nil`
    public var value: Content? {
        switch self {
        case .loaded(next: let content):
            content
        case .loading:
            nil
        }
    }

    /// Returns `true` for `.loading` state
    public var isLoading: Bool {
        switch self {
        case .loading:
            true
        case .loaded:
            false
        }
    }
}

extension LoadingState: Equatable where Content: Equatable {}
