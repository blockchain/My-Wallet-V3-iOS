//
//  PersonalDetailsCoordinator.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

class PersonalDetailsCoordinator: NSObject {

    fileprivate let service: PersonalDetailsService
    fileprivate weak var interface: PersonalDetailsInterface?

    init(interface: PersonalDetailsInterface) {
        self.service = PersonalDetailsService()
        self.interface = interface
        super.init()

        if let controller = interface as? KYCPersonalDetailsController {
            controller.delegate = self
        }
    }
}

extension PersonalDetailsCoordinator: PersonalDetailsDelegate {
    func onSubmission(_ input: KYCUpdatePersonalDetailsRequest, completion: @escaping () -> Void) {
        interface?.primaryButtonEnabled(false)
        interface?.primaryButtonActivityIndicator(.visible)
        service.update(personalDetails: input) { [weak self] (error) in
            guard let this = self else { return }
            this.interface?.primaryButtonActivityIndicator(.hidden)

            if let err = error {
                // TODO: Error state
                Logger.shared.error("Failed to update personal details: \(err)")
            } else {
                completion()
            }
            this.interface?.primaryButtonEnabled(true)
        }
    }
}
