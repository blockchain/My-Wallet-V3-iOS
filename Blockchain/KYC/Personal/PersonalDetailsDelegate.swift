//
//  PersonalDetailsDelegate.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol PersonalDetailsDelegate: class {
    func onStart()
    func onSubmission(_ input: PersonalDetails)
}
