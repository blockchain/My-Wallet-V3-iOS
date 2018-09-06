//
//  ExchangeDetailInterface.swift
//  Blockchain
//
//  Created by Alex McGregor on 9/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

protocol ExchangeDetailInterface: class {
    func updateBackgroundColor(_ color: UIColor)
    func navigationBarVisibility(_ visibility: Visibility)
    func rightBarButtonVisibility(_ visibility: Visibility)
    func updateTitle(_ value: String)
}
