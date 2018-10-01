//
//  Rx+Helpers.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/1/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

extension CompositeDisposable {
    @discardableResult func insertWithDiscardableResult(_ disposable: Disposable) -> CompositeDisposable.DisposeKey? {
        return self.insert(disposable)
    }
}
