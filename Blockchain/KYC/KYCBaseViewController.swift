//
//  KYCBaseViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class KYCBaseViewController: UIViewController, KYCCoordinatorDelegate {

    var coordinator: KYCCoordinator!
    var pageType: KYCPageType = .welcome

    class func make(with coordinator: KYCCoordinator) -> KYCBaseViewController {
        assertionFailure("Should be implemented by subclasses")
        return KYCBaseViewController()
    }

    func apply(model: KYCPageModel) {
        Logger.shared.debug("Should be overriden to do something with KYCPageModel.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // TICKET: IOS-1236 - Refactor KYCBaseViewController NavigationBarItem Titles
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coordinator.delegate = self
        coordinator.handle(event: .pageWillAppear(pageType))
    }

    override func viewWillDisappear(_ animated: Bool) {
        coordinator.delegate = nil
        super.viewWillDisappear(animated)
    }
}
