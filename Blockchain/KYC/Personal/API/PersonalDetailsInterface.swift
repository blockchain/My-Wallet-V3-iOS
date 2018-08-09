//
//  PersonalDetailsInterface.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol PersonalDetailsInterface: class {
    func nextPage()
    func rightBarButton(_ visibility: Visibility)
    func primaryButtonEnabled(_ enabled: Bool)
    func updateBarButtonActivityIndicator(_ visibility: Visibility)
    func populatePersonalDetailFields(_ details: PersonalDetails)
}
