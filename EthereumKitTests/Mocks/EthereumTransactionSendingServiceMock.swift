//
//  EthereumTransactionSendingServiceMock.swift
//  EthereumKitTests
//
//  Created by Jack on 14/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import PlatformKit
@testable import EthereumKit

enum EthereumTransactionCreationServiceMockError: Error {
    case mockError
}

class EthereumTransactionSendingServiceMock: EthereumTransactionSendingServiceAPI {
    var lastSendTransaction: EthereumTransactionCandidate?
    var lastSendKeyPair: EthereumKeyPair?
    var sendTransactionResponse: Single<EthereumTransactionPublished> =
        Single.error(EthereumTransactionCreationServiceMockError.mockError)
    func send(transaction: EthereumTransactionCandidate, keyPair: EthereumKeyPair) -> Single<EthereumTransactionPublished> {
        lastSendTransaction = transaction
        lastSendKeyPair = keyPair
        return sendTransactionResponse
    }
}
