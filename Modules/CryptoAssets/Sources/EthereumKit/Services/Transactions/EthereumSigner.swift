// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import ToolKit
import WalletCore

public enum EthereumSignerError: Error {
    case failedPersonalMessageSign
    case failedSignTypedData
    case incorrectChainId
}

protocol EthereumSignerAPI {

    func sign(
        transaction: EthereumTransactionCandidateCosted,
        keyPair: EthereumKeyPair
    ) -> Result<EthereumTransactionEncoded, EthereumSignerError>

    /// The sign method calculates an Ethereum specific signature with: sign(keccak256("\x19Ethereum Signed Message:\n" + len(message) + message))).
    /// Used for `eth_sign` and `personal_sign` WalletConnect methods.
    func sign(
        messageData: Data,
        keyPair: EthereumKeyPair
    ) -> Result<Data, EthereumSignerError>

    func signTypedData(
        messageJson: String,
        keyPair: EthereumKeyPair
    ) -> Result<Data, EthereumSignerError>
}

final class EthereumSigner: EthereumSignerAPI {

    func sign(
        transaction: EthereumTransactionCandidateCosted,
        keyPair: EthereumKeyPair
    ) -> Result<EthereumTransactionEncoded, EthereumSignerError> {
        var input = transaction.transaction
        input.privateKey = keyPair.privateKey.data
        let output: EthereumSigningOutput = AnySigner.sign(input: input, coin: .ethereum)
        let signed = EthereumTransactionEncoded(transaction: output)
        return .success(signed)
    }

    func sign(
        messageData: Data,
        keyPair: EthereumKeyPair
    ) -> Result<Data, EthereumSignerError> {
        personalSignData(messageData: messageData)
            .map { personalSignData -> Data in
                WalletCore.Hash.keccak256(data: personalSignData)
            }
            .flatMap { data -> Result<Data, EthereumSignerError> in
                guard let pk = WalletCore.PrivateKey(data: keyPair.privateKey.data) else {
                    return .failure(.failedPersonalMessageSign)
                }
                guard let signed = pk.sign(digest: data, curve: .secp256k1) else {
                    return .failure(.failedPersonalMessageSign)
                }
                return .success(signed)
            }
    }

    func signTypedData(
        messageJson: String,
        keyPair: EthereumKeyPair
    ) -> Result<Data, EthereumSignerError> {
        encodeTypedData(messageJson: messageJson)
            .flatMap { data -> Result<Data, EthereumSignerError> in
                guard let pk = WalletCore.PrivateKey(data: keyPair.privateKey.data) else {
                    return .failure(.failedSignTypedData)
                }
                guard let signed = pk.sign(digest: data, curve: .secp256k1) else {
                    return .failure(.failedSignTypedData)
                }
                return .success(signed)
            }
    }

    private func personalSignData(messageData: Data) -> Result<Data, EthereumSignerError> {
        let prefix = "\u{19}Ethereum Signed Message:\n"
        let countString = String(messageData.count)
        guard let prefixData = (prefix + countString).data(using: .ascii) else {
            return .failure(.failedPersonalMessageSign)
        }
        return .success(prefixData + messageData)
    }

    private func encodeTypedData(messageJson: String) -> Result<Data, EthereumSignerError> {
        let data = EthereumAbi.encodeTyped(messageJson: messageJson)
        return data.isEmpty ?
            .failure(.failedSignTypedData)
            : .success(data)
    }
}

public func ethereumPersonalSign(message: Data, privateKey: Data) throws -> Data {
    guard let pk = WalletCore.PrivateKey(data: privateKey) else {
        throw EthereumSignerError.failedPersonalMessageSign
    }
    let hashed = WalletCore.Hash.keccak256(data: message)
    guard let signed = pk.sign(digest: hashed, curve: .secp256k1) else {
        throw EthereumSignerError.failedPersonalMessageSign
    }
    return signed
}
