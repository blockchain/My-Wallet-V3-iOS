// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RIBs
import UIComponentsKit

public protocol AddNewBankAccountInteractable: Interactable {
    var router: AddNewBankAccountRouting? { get set }
    var listener: AddNewBankAccountListener? { get set }
}

public protocol AddNewBankAccountViewControllable: ViewControllable {}

public final class AddNewBankAccountRouter: ViewableRouter<AddNewBankAccountInteractable, AddNewBankAccountViewControllable>,
    AddNewBankAccountRouting
{

    override public init(
        interactor: AddNewBankAccountInteractable,
        viewController: AddNewBankAccountViewControllable
    ) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    override public func didLoad() {
        super.didLoad()
    }

    public func showTermsScreen(link: TitledLink) {
        let webRouter = WebViewRouter(topMostViewControllerProvider: viewController.uiviewController)
        webRouter.launchRelay.accept(link)
    }
}
