// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

// MARK: - Builder

public protocol LinkBankFlowRootBuildable {
    /// Builds the flow for linking a new bank
    /// - Parameter presentingController: A `NavigationControllerAPI` object that acts as a presenting controller
    func build() -> LinkBankFlowStarter
}

public final class LinkBankFlowRootBuilder: LinkBankFlowRootBuildable {

    public init() {}

    public func build() -> LinkBankFlowStarter {
        let splashScreenBuilder = LinkBankSplashScreenBuilder()
        let yodleeScreenBuilder = YodleeScreenBuilder()
        let failureScreenBuilder = LinkBankFailureScreenBuilder()
        let interactor = LinkBankFlowRootInteractor()
        return LinkBankFlowRootRouter(
            interactor: interactor,
            splashScreenBuilder: splashScreenBuilder,
            yodleeScreenBuilder: yodleeScreenBuilder,
            failureScreenBuilder: failureScreenBuilder
        )
    }
}
