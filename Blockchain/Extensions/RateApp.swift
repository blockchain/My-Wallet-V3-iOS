//
//  RateApp.swift
//  Blockchain
//
//  Created by Maurice A. on 5/22/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

// MARK: - Rate Application

extension UIApplication {
    @objc func rateApp() {
        let url = URL(string: "\(Constants.Url.appStoreLinkPrefix)\(Constants.AppStore.AppID)")!
        UIApplication.shared.openURL(url)
    }
}
