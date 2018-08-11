//
//  PersonalDetailsService.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class PersonalDetailsService: NSObject, PersonalDetailsAPI {

    func update(personalDetails: PersonalDetails, with completion: @escaping PersonalDetailsUpdateCompletion) {
        KYCNetworkRequest(
            put: .updateUserDetails(userId: personalDetails.identifier),
            parameters: personalDetails,
            taskSuccess: { _ in
                completion(nil)
        }) { (error) in
            completion(error)
        }
    }
}
