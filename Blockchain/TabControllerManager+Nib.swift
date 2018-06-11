//
//  TabControllerManager+Nib.swift
//  Blockchain
//
//  Created by Maurice A. on 6/8/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension TabControllerManager {
    static func instanceFromNib() -> TabControllerManager {
        let nib = UINib(nibName: "TabController", bundle: Bundle.main)
        let contents = nib.instantiate(withOwner: nil, options: nil)
        return contents.first { item -> Bool in
            item is TabControllerManager
            } as! TabControllerManager
    }
}
