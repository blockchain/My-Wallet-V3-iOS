// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

public protocol SwapActivityItemEventServiceAPI {
    var swapActivityEvents: Single<[SwapActivityItemEvent]> { get }
    var swapActivityObservable: Observable<[SwapActivityItemEvent]> { get }

    /// `ActivityItemEventsLoadingState` for only custodial swaps
    var custodial: Observable<ActivityItemEventsLoadingState> { get }
    /// `ActivityItemEventsLoadingState` for only nonCustodial swaps
    var nonCustodial: Observable<ActivityItemEventsLoadingState> { get }
    /// `ActivityItemEventsLoadingState` for all swaps
    var state: Observable<ActivityItemEventsLoadingState> { get }

    /// Forces the service to fetch events.
    /// Note that this should ignore the cache.
    var fetchTriggerRelay: PublishRelay<Void> { get }
}
