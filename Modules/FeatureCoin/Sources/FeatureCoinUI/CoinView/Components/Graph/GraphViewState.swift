// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import Errors
import FeatureCoinDomain
import Foundation

public struct GraphViewState: Equatable {
    @BindingState var selected: Int?
    var interval: Series

    var result: Result<GraphData, NetworkError>?
    var isFetching: Bool

    var hideOnFailure: Bool
    var tolerance: Int
    var density: Int
    var date: Date

    public init(
        interval: Series = .day,
        result: Result<GraphData, NetworkError>? = nil,
        isFetching: Bool = false,
        hideOnFailure: Bool = false,
        tolerance: Int = 2,
        density: Int = 250,
        date: Date = Date()
    ) {
        self.interval = interval
        self.result = result
        self.isFetching = isFetching
        self.hideOnFailure = hideOnFailure
        self.tolerance = tolerance
        self.density = density
        self.date = date
    }
}
