//
//  UINavigationBar+TitleAttributes.swift
//  Blockchain
//
//  Created by Maurice A. on 6/10/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension UINavigationBar {
    @objc static let standardTitleTextAttributes = [
        NSAttributedString.Key.font: UIFont(name: "Montserrat-Regular", size: 20)!,
        NSAttributedString.Key.foregroundColor: UIColor.white
    ]
    @objc static let largeTitleTextAttributes = [
        NSAttributedString.Key.font: UIFont(name: "Montserrat-Regular", size: 23)!,
        NSAttributedString.Key.foregroundColor: UIColor.white
    ]
}
