//
//  SearchControllerDelegate.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

protocol SearchSelection {}

protocol SearchControllerDelegate: class {
    func onStart()
    func onSubmission(_ selection: SearchSelection)
    func onSelection(_ selection: SearchSelection)
    func onSubmission(_ address: UserAddress, completion: @escaping () -> Void)
    func onSearchRequest(_ query: String)
    func onSearchViewCancel()
}
