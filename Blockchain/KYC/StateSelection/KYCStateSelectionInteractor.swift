//
//  KYCStateSelectionInteractor.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

class KYCStateSelectionInteractor {

    func fetchState(for country: KYCCountry) -> Single<[KYCState]> {
        return KYCNetworkRequest.request(
            get: .listOfStates,
            pathComponents: country.urlPathComponentsForState,
            type: [KYCState].self
        )
    }
}
