//
//  WithdrawBuilder.swift
//  BuySellUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 30/09/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RIBs
import UIKit

public final class WithdrawBuilder: WithdrawBuildable {

    private let currency: FiatCurrency
    
    public init(currency: FiatCurrency) {
        self.currency = currency
    }

    public func build() -> (flow: WithdrawFlowStarter, controller: UINavigationController) {
        let rootNavigation = RootNavigation()
        let linkedBanksBuilder = LinkedBanksSelectionBuilder(currency: currency)
        let enterAmountBuilder = WithdrawAmountPageBuilder(currency: currency)
        let checkountPageBuilder = CheckoutPageBuilder()
        let interactor = WithdrawRootInteractor()
        let router = WithdrawRootRouter(interactor: interactor,
                                        navigation: rootNavigation,
                                        selectBanksBuilder: linkedBanksBuilder,
                                        enterAmountBuilder: enterAmountBuilder,
                                        checkoutPageBuilder: checkountPageBuilder)
        return (router, rootNavigation)
    }

}
