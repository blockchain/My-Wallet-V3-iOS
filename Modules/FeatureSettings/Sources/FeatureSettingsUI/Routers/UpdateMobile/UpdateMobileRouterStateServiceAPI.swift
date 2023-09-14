// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxRelay
import RxSwift

protocol UpdateMobileStateReceiverServiceAPI: AnyObject {

    /// The action that should be executed, the `next` action
    /// is coupled with the current state
    var action: Observable<UpdateMobileRouterStateService.Action> { get }
}

/// A composition of all of Simple-Buy state-services
typealias UpdateMobileStateServiceAPI =
    RoutingNextStateEmitterAPI &
    RoutingPreviousStateEmitterAPI & UpdateMobileStateReceiverServiceAPI
