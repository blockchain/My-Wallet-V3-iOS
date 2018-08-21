//
//  PersonalDetailsAPI.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

typealias PersonalDetailsUpdateCompletion = ((Error?) -> Void)

protocol PersonalDetailsAPI {
    func update(personalDetails: KYCUpdatePersonalDetailsRequest, with completion: @escaping PersonalDetailsUpdateCompletion)
}
