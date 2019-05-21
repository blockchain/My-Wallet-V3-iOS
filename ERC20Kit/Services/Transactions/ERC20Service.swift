//
//  ERC20Service.swift
//  ERC20Kit
//
//  Created by Jack on 19/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import BigInt
import web3swift
import PlatformKit
import EthereumKit

// TODO:
// * Add ERC20 field in ethereum metadata
// * Add tx_notes to metadata

enum ERC20ServiceError: Error {
    case invalidCyptoValue
    case insufficientEthereumBalance
    case insufficientTokenBalance
}

public class ERC20Service<Token: ERC20Token>: ERC20API {
    
    enum ERC20ContractMethod: String {
        case transfer
    }
    
    private var tokenAssetAccountDetails: Single<ERC20AssetAccountDetails> {
        return assetAccountRepository.assetAccountDetails.asObservable().asSingle()
    }
    
    private var ethereumAssetAccountDetails: Single<EthereumAssetAccountDetails> {
        return ethereumAssetAccountRepository.assetAccountDetails.asObservable().asSingle()
    }
    
    private let assetAccountRepository: ERC20AssetAccountRepository<Token>
    private let ethereumAssetAccountRepository: EthereumAssetAccountRepository
    private let feeService: EthereumFeeServiceAPI

    public init(assetAccountRepository: ERC20AssetAccountRepository<Token>,
                ethereumAssetAccountRepository: EthereumAssetAccountRepository,
                feeService: EthereumFeeServiceAPI) {
        self.assetAccountRepository = assetAccountRepository
        self.ethereumAssetAccountRepository = ethereumAssetAccountRepository
        self.feeService = feeService
    }
    
    public func transfer(to: EthereumKit.EthereumAddress, amount cryptoValue: ERC20TokenValue<Token>) -> Single<EthereumTransactionCandidate> {
        let tokenAmount = BigUInt(cryptoValue.amount)
        return Single.zip(feeService.fees, tokenAssetAccountDetails, ethereumAssetAccountDetails, transferTransaction(to: to, amount: tokenAmount))
            .flatMap { tuple -> Single<EthereumTransactionCandidate> in
                let (fee, tokenAccount, ethereumAccount, transaction) = tuple
                
                let gasPrice = BigUInt(fee.regular.amount)
                let gasLimitContract = BigUInt(fee.gasLimitContract)
                let tokenBalance = BigUInt(tokenAccount.balance.amount)
                let ethereumBalance = BigUInt(ethereumAccount.balance.amount)
                let ethereumTransactionFee = gasPrice * gasLimitContract
                
                print("             tokenAmount: \(tokenAmount.string(unitDecimals: Token.assetType.maxDecimalPlaces))")
                print("                gasPrice: \(gasPrice.string(unitDecimals: Token.assetType.maxDecimalPlaces))")
                print("        gasLimitContract: \(gasLimitContract.string(unitDecimals: Token.assetType.maxDecimalPlaces))")
                print("            tokenBalance: \(tokenBalance.string(unitDecimals: Token.assetType.maxDecimalPlaces))")
                print("  ethereumTransactionFee: \(ethereumTransactionFee.string(unitDecimals: CryptoCurrency.ethereum.maxDecimalPlaces))")
                
                guard ethereumTransactionFee < ethereumBalance else {
                    throw ERC20ServiceError.insufficientEthereumBalance
                }
                
                guard tokenAmount <= tokenBalance else {
                    throw ERC20ServiceError.insufficientTokenBalance
                }
                
                let tokenBalanceAfterTransaction = tokenBalance - tokenAmount
                
                print("tokenBalanceAfterTransaction: \(tokenBalanceAfterTransaction.string(unitDecimals: Token.assetType.maxDecimalPlaces))")
                
                let ethereumBalanceAfterTransaction = ethereumBalance - ethereumTransactionFee
                
                print("ethereumBalanceAfterTransaction: \(ethereumBalanceAfterTransaction.string(unitDecimals: CryptoCurrency.ethereum.maxDecimalPlaces))")
                
                let transactionCandidate = EthereumTransactionCandidate(
                    to: EthereumAddress(rawValue: transaction.to.address)!,
                    gasPrice: BigUInt(fee.regular.amount),
                    gasLimit: BigUInt(fee.gasLimitContract),
                    value: BigUInt(0),
                    data: transaction.data
                )
                
                return Single.just(transactionCandidate)
        }
    }
    
    private func transferTransaction(to: EthereumKit.EthereumAddress, amount: BigUInt) -> Single<EthereumTransaction> {
        let transaction: EthereumTransaction
        do {
            let contractAddress: web3swift.Address = web3swift.Address(
                Token.contractAddress.rawValue
            )
            let contract = try ContractV2(Web3Utils.erc20ABI, at: contractAddress)
            let method: ERC20ContractMethod = .transfer
            let options = Web3Options()
            let toAddress: web3swift.Address = web3swift.Address(to.rawValue)
            let parameters: [Any] = [ toAddress, amount ]
            transaction = try contract.method(
                method.rawValue,
                parameters: parameters,
                options: options
            )
        } catch {
            return Single.error(error)
        }
        return Single.just(transaction)
    }
}
