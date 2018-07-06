//
//  PinInteractor.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/4/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

/// Interactor for the pin. This component interacts with the Blockchain API and the local
/// pin data store. When the pin is updated, the pin is also stored on the keychain.
@objc class PinInteractor: NSObject {

    static let shared = PinInteractor()

    @objc class func sharedInstance() -> PinInteractor { return shared }

    private let walletService: WalletService

    init(walletService: WalletService = WalletService.shared) {
        self.walletService = walletService
    }

    /// Validates if the provided pin payload (i.e. pin code and pin key combination) is correct.
    /// Calling this method will also handle updating the local pin store (i.e. the keychain),
    /// depending on the response for the remote pin store.
    ///
    /// - Parameter pinPayload: the PinPayload
    /// - Returns: an Observable returning the response
    func validatePin(_ pinPayload: PinPayload) -> Single<GetPinResponse> {
        return self.walletService.validatePin(pinPayload)
            .do(onSuccess: { response in
                // Clear pin from keychain if the user exceeded the number of retries when entering the pin.
                if response.statusCode == .deleted {
                    BlockchainSettings.App.shared.pin = nil
                }
            })
    }
}
