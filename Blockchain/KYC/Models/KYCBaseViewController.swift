//
//  KYCBaseViewController.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class KYCBaseViewController: UIViewController {

    var coordinator: KYCCoordinator!
    var pageType: KYCPageType = .welcome

    class func make(with coordinator: KYCCoordinator) -> KYCBaseViewController {
        assertionFailure("Should be implemented by subclasses")
        return KYCBaseViewController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coordinator.handle(event: .pageWillAppear(pageType))
    }

}

