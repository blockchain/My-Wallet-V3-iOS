//
//  MockEthereumWalletTestData.swift
//  EthereumKitTests
//
//  Created by Jack on 09/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import web3swift
import BigInt
@testable import EthereumKit

struct MockEthereumWalletTestData {
    static let walletId = "22d57944-bb00-49e5-bc96-e2c31e0a0ff1"
    static let email = "test@blockchain.com"
    
    static let mnemonic = "exercise loop fly noodle various century tooth remember relief castle entire high"
    static let password = "M6rv3L9JavGy3Si%PD5EHTKPz$E9N5"
    static let account = "0xE408d13921DbcD1CBcb69840e4DA465Ba07B7e5e".lowercased()
    
    static let privateKeyHex = "de6e182c9456edeb1148387dadc8f981905377279feb9547d095152ef0f569d9"
    static let privateKeyBase64 = "3m4YLJRW7esRSDh9rcj5gZBTdyef65VH0JUVLvD1adk="
    static let privateKeyData = Data.fromHex(MockEthereumWalletTestData.privateKeyHex)!
    
    static let privateKey = EthereumPrivateKey(
        mnemonic: MockEthereumWalletTestData.mnemonic,
        password: MockEthereumWalletTestData.password,
        data: MockEthereumWalletTestData.privateKeyData
    )
    static let keyPair = EthereumKeyPair(
        accountID: MockEthereumWalletTestData.account,
        privateKey: MockEthereumWalletTestData.privateKey
    )
    
    struct Transaction {
        static let to = "0x3535353535353535353535353535353535353535"
        static let value: BigUInt = 1
        static let nonce: BigUInt = 9
        static let gasPrice: BigUInt = 11_000_000_000
        static let gasLimit: BigUInt = 21_000
        static let gasLimitContract: BigUInt = 65_000
        static let data: Data? = Data()
    }
}

class EthereumTransactionCandidateBuilder {
    var to: EthereumKit.EthereumAddress? = EthereumKit.EthereumAddress(rawValue: "0x3535353535353535353535353535353535353535")
    var value: BigUInt? = MockEthereumWalletTestData.Transaction.value
    var gasPrice: BigUInt? = MockEthereumWalletTestData.Transaction.gasPrice
    var gasLimit: BigUInt? = MockEthereumWalletTestData.Transaction.gasLimit
    var data: Data?

    func with(toAccountAddress: String) -> Self {
        self.to = EthereumKit.EthereumAddress(rawValue: toAccountAddress)
        return self
    }
    
    func with(value: BigUInt) -> Self {
        self.value = value
        return self
    }
    
    func with(gasPrice: BigUInt) -> Self {
        self.gasPrice = gasPrice
        return self
    }
    
    func build() -> EthereumTransactionCandidate? {
        guard
            let to = to,
            let value = value,
            let gasPrice = gasPrice,
            let gasLimit = gasLimit
        else {
            return nil
        }
        return EthereumTransactionCandidate(
            to: to,
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            value: value,
            data: data
        )
    }
}

class EthereumTransactionCandidateCostedBuilder {
    
    var web3swiftTransaction: web3swift.EthereumTransaction? 
    
    var candidate: EthereumTransactionCandidate? {
        didSet {
            candidateUpdated()
        }
    }
    
    init(candidate: EthereumTransactionCandidate = EthereumTransactionCandidateBuilder().build()!) {
        self.candidate = candidate
        candidateUpdated()
    }
    
    func with(candidate: EthereumTransactionCandidate) -> Self {
        self.candidate = candidate
        candidateUpdated()
        return self
    }
    
    func with(web3swiftTransaction: web3swift.EthereumTransaction) -> Self {
        self.web3swiftTransaction = web3swiftTransaction
        return self
    }
    
    func build() -> EthereumTransactionCandidateCosted? {
        guard let web3swiftTransaction = web3swiftTransaction else {
            return nil
        }
        return try? EthereumTransactionCandidateCosted(
            transaction: web3swiftTransaction
        )
    }
    
    private func candidateUpdated() {
        web3swiftTransaction = web3swift.EthereumTransaction(
            candidate: candidate!
        )
    }
}

class EthereumTransactionCandidateSignedBuilder {
    var costed: EthereumTransactionCandidateCosted? {
        didSet {
            web3swiftTransaction = costed?.transaction
        }
    }
    
    var web3swiftTransaction: web3swift.EthereumTransaction?
    
    var candidate: EthereumTransactionCandidate? {
        didSet {
            candidateUpdated()
        }
    }

    init() {}
    
    init(candidate: EthereumTransactionCandidate) {
        self.candidate = candidate
        candidateUpdated()
    }
    
    func with(costed: EthereumTransactionCandidateCosted) -> Self {
        self.costed = costed
        return self
    }
    
    func with(web3swiftTransaction: web3swift.EthereumTransaction) -> Self {
        self.web3swiftTransaction = web3swiftTransaction
        return self
    }
    
    func build() -> EthereumTransactionCandidateSigned? {
        guard var transaction = web3swiftTransaction else {
            return nil
        }
        
        let privateKeyData = MockEthereumWalletTestData.privateKeyData
        
        transaction.nonce = MockEthereumWalletTestData.Transaction.nonce
        
        // swiftlint:disable force_try
        try! Web3Signer.EIP155Signer.sign(transaction: &transaction, privateKey: privateKeyData, useExtraEntropy: false)
        // swiftlint:enable force_try
        
        return try? EthereumTransactionCandidateSigned(
            transaction: transaction
        )
    }
    
    private func candidateUpdated() {
        let costed = EthereumTransactionCandidateCostedBuilder()
            .with(candidate: candidate!)
            .build()!
        self.costed = costed
    }

}

class EthereumTransactionFinalisedBuilder {
    var signed: EthereumTransactionCandidateSigned? {
        didSet {
            web3swiftTransaction = signed?.transaction
        }
    }
    
    var web3swiftTransaction: web3swift.EthereumTransaction?
    
    var candidate: EthereumTransactionCandidate? {
        didSet {
            candidateUpdated()
        }
    }
    
    init() {}
    
    init(candidate: EthereumTransactionCandidate) {
        self.candidate = candidate
        candidateUpdated()
    }
    
    func with(candidate: EthereumTransactionCandidate) -> Self {
        self.candidate = candidate
        candidateUpdated()
        return self
    }
    
    func with(signed: EthereumTransactionCandidateSigned) -> Self {
        self.signed = signed
        return self
    }
    
    func with(web3swiftTransaction: web3swift.EthereumTransaction) -> Self {
        self.web3swiftTransaction = web3swiftTransaction
        return self
    }
    
    func build() -> EthereumTransactionFinalised? {
        guard let web3swiftTransaction = web3swiftTransaction else {
            return nil
        }
        guard let encodedData = web3swiftTransaction.encode() else {
            return nil
        }
        let rawTxHexString = encodedData.hex.withHex.lowercased()
        return EthereumTransactionFinalised(
            transaction: web3swiftTransaction,
            rawTx: rawTxHexString
        )
    }
    
    private func candidateUpdated() {
        let costed = EthereumTransactionCandidateCostedBuilder()
            .with(candidate: candidate!)
            .build()!
        let signed = EthereumTransactionCandidateSignedBuilder()
            .with(costed: costed)
            .build()
        self.signed = signed
    }
}

class EthereumTransactionPublishedBuilder {
    
    var finalised: EthereumTransactionFinalised? =
        EthereumTransactionFinalisedBuilder().build()
    
    var candidate: EthereumTransactionCandidate? {
        didSet {
            candidateUpdated()
        }
    }
    
    var transactionHash: String?
    
    init(candidate: EthereumTransactionCandidate = EthereumTransactionCandidateBuilder().build()!) {
        self.candidate = candidate
        candidateUpdated()
    }
    
    func with(candidate: EthereumTransactionCandidate) -> Self {
        self.candidate = candidate
        candidateUpdated()
        return self
    }
    
    func with(finalised: EthereumTransactionFinalised) -> Self {
        self.finalised = finalised
        return self
    }
    
    func with(transactionHash: String) -> Self {
        self.transactionHash = transactionHash
        return self
    }
    
    func build() -> EthereumTransactionPublished? {
        guard let finalised = finalised else {
            return nil
        }
        guard let transactionHash = transactionHash else {
            return EthereumTransactionPublished(
                finalisedTransaction: finalised,
                transactionHash: finalised.transactionHash
            )
        }
        return EthereumTransactionPublished(
            finalisedTransaction: finalised,
            transactionHash: transactionHash
        )
    }
    
    private func candidateUpdated() {
        let costed = EthereumTransactionCandidateCostedBuilder()
            .with(candidate: candidate!)
            .build()!
        let signed = EthereumTransactionCandidateSignedBuilder()
            .with(costed: costed)
            .build()!
        let finalised = EthereumTransactionFinalisedBuilder()
            .with(signed: signed)
            .build()!
        self.finalised = finalised
    }
}

extension web3swift.EthereumTransaction {
    init(candidate: EthereumTransactionCandidate, nonce: BigUInt = 9) {
        self.init(
            nonce: nonce,
            gasPrice: candidate.gasPrice,
            gasLimit: candidate.gasLimit,
            to: candidate.to.web3swiftAddress,
            value: candidate.value,
            data: candidate.data ?? Data()
        )
        self.UNSAFE_setChainID(NetworkId.mainnet)
    }
}
