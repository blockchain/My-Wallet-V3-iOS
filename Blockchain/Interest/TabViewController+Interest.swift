//
//  TabViewController+Interest.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/28/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import InterestUIKit

extension TabViewController {
    func showInterestIdentityVerificationScreen(_ controller: InterestDashboardAnnouncementViewController) {
        controller.transitioningDelegate = sheetPresenter
        controller.modalPresentationStyle = .custom
        controller.isModalInPresentation = true
        present(controller, animated: true, completion: nil)
    }
}

