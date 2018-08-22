//
//  Nibable.swift
//  Blockchain
//
//  Created by kevinwu on 8/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol Nibable: class {
    static var defaultNibName: String { get }
}

extension Nibable where Self: UIView {
    static var defaultNibName: String {
        return String(describing: self)
    }

    static func makeFromNib() -> Self {
        let nib = UINib(nibName: defaultNibName, bundle: Bundle.main)
        let contents = nib.instantiate(withOwner: nil, options: nil)
        return contents.first { $0 is Self } as! Self
    }
}

extension UIView: Nibable { }
