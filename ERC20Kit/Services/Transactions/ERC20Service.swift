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

public enum ERC20ServiceError: Error {
    case invalidCyptoValue
    case insufficientEthereumBalance
    case insufficientTokenBalance
    case invalidEthereumAddress
}

public class ERC20Service<Token: ERC20Token>: ERC20API, ERC20TransactionEvaluationAPI {
    
    enum ERC20ContractMethod: String {
        case transfer
    }
    
    private var tokenAssetAccountDetails: Single<ERC20AssetAccountDetails> {
        return assetAccountRepository.assetAccountDetails.asObservable().asSingle()
    }
    
    private var ethereumAssetAccountDetails: Single<EthereumAssetAccountDetails> {
        return ethereumAssetAccountRepository.assetAccountDetails.asObservable().asSingle()
    }
    
    private let bridge: ERC20BridgeAPI
    private let assetAccountRepository: ERC20AssetAccountRepository<Token>
    private let ethereumAssetAccountRepository: EthereumAssetAccountRepository
    private let feeService: EthereumFeeServiceAPI

    public init(with bridge: ERC20BridgeAPI,
                assetAccountRepository: ERC20AssetAccountRepository<Token>,
                ethereumAssetAccountRepository: EthereumAssetAccountRepository,
                feeService: EthereumFeeServiceAPI) {
        self.bridge = bridge
        self.assetAccountRepository = assetAccountRepository
        self.ethereumAssetAccountRepository = ethereumAssetAccountRepository
        self.feeService = feeService
    }
    
    public func transfer(to: EthereumKit.EthereumAddress, amount cryptoValue: ERC20TokenValue<Token>) -> Single<EthereumTransactionCandidate> {
        return buildTransactionCandidate(to: to, amount: cryptoValue, fee: nil)
    }
    
    public func transfer(
        to: EthereumKit.EthereumAddress,
        amount cryptoValue: ERC20TokenValue<Token>,
        fee: EthereumTransactionFee
        ) -> Single<EthereumTransactionCandidate> {
        return buildTransactionCandidate(to: to, amount: cryptoValue, fee: fee)
    }
    
    public func transfer(proposal: ERC20TransactionProposal<Token>, to address: EthereumKit.EthereumAddress) -> Single<EthereumTransactionCandidate> {
        guard address.isValid else { return Single.error(ERC20ServiceError.invalidEthereumAddress) }
        return buildTransactionCandidate(to: address, amount: proposal.value, fee: nil)
    }
    
    private func buildTransactionCandidate(
        to: EthereumKit.EthereumAddress,
        amount cryptoValue: ERC20TokenValue<Token>,
        fee: EthereumTransactionFee? = nil
        ) -> Single<EthereumTransactionCandidate> {
        let tokenAmount = BigUInt(cryptoValue.amount)
        return Single.zip(
            feesFor(feeValue: fee),
            tokenAssetAccountDetails,
            ethereumAssetAccountDetails,
            transferTransaction(to: to, amount: tokenAmount)
            )
            .flatMap(weak: self, { (self, tuple) -> Single<EthereumTransactionCandidate> in
                let (fee, tokenAccount, ethereumAccount, transaction) = tuple
                
                try self.validateTokenAndBalanceCoverage(
                    cryptoValue,
                    fee: fee,
                    tokenAcocuntDetails: tokenAccount,
                    assetAccountDetails: ethereumAccount
                )
                
                let transactionCandidate = EthereumTransactionCandidate(
                    to: EthereumAddress(rawValue: transaction.to.address)!,
                    gasPrice: BigUInt(fee.priority.amount),
                    gasLimit: BigUInt(fee.gasLimitContract),
                    value: BigUInt(0),
                    data: transaction.data
                )
                
                return Single.just(transactionCandidate)
            })
    }
    
    // MARK: ERC20TransactionEvaluationAPI
    
    public func evaluate(amount cryptoValue: ERC20TokenValue<Token>) -> Single<ERC20TransactionProposal<Token>> {
        return buildProposal(with: cryptoValue)
    }
    
    public func evaluate(amount cryptoValue: ERC20TokenValue<Token>, fee: EthereumTransactionFee) -> Single<ERC20TransactionProposal<Token>> {
        return buildProposal(with: cryptoValue, fee: fee)
    }
    
    private func buildProposal(
        with cryptoValue: ERC20TokenValue<Token>,
        fee: EthereumTransactionFee? = nil)
        -> Single<ERC20TransactionProposal<Token>> {
        return Single.zip(feesFor(feeValue: fee), tokenAssetAccountDetails, ethereumAssetAccountDetails)
            .flatMap(weak: self, { (self, tuple) -> Single<ERC20TransactionProposal<Token>> in
                let (fee, tokenAccount, ethereumAccount) = tuple
                
                try self.validateTokenAndBalanceCoverage(
                    cryptoValue,
                    fee: fee,
                    tokenAcocuntDetails: tokenAccount,
                    assetAccountDetails: ethereumAccount
                )
                
                let transactionProposal = ERC20TransactionProposal(
                    from: EthereumKit.EthereumAddress(stringLiteral: ethereumAccount.account.accountAddress),
                    gasPrice: BigUInt(fee.priority.amount),
                    gasLimit: BigUInt(fee.gasLimitContract),
                    value: cryptoValue
                )
                
                return Single.just(transactionProposal)
            })
    }
    
    private func transferTransaction(to: EthereumKit.EthereumAddress, amount: BigUInt) -> Single<web3swift.EthereumTransaction> {
        let transaction: web3swift.EthereumTransaction
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
    
    private func feesFor(feeValue: EthereumTransactionFee?) -> Single<EthereumTransactionFee> {
        guard let fee = feeValue else { return feeService.fees }
        return Single.just(fee)
    }
    
    private func validateTokenAndBalanceCoverage(
        _ cryptoValue: ERC20TokenValue<Token>,
        fee: EthereumTransactionFee,
        tokenAcocuntDetails: ERC20AssetAccountDetails,
        assetAccountDetails: EthereumAssetAccountDetails) throws {
        
        let tokenAmount = BigUInt(cryptoValue.amount)
        let gasPrice = BigUInt(fee.priority.amount)
        let gasLimitContract = BigUInt(fee.gasLimitContract)
        let tokenBalance = BigUInt(tokenAcocuntDetails.balance.amount)
        let ethereumBalance = BigUInt(assetAccountDetails.balance.amount)
        let ethereumTransactionFee = gasPrice * gasLimitContract
        
        guard ethereumTransactionFee < ethereumBalance else {
            throw ERC20ServiceError.insufficientEthereumBalance
        }
        
        guard tokenAmount <= tokenBalance else {
            throw ERC20ServiceError.insufficientTokenBalance
        }
    }
}

extension ERC20Service: ERC20TransactionMemoAPI {
    public func memo(for transactionHash: String) -> Single<String?> {
        return bridge.memo(
            for: transactionHash,
            tokenContractAddress: Token.contractAddress.rawValue
        )
    }
    
    public func save(transactionMemo: String, for transactionHash: String) -> Completable {
        return bridge.save(
            transactionMemo: transactionMemo,
            for: transactionHash,
            tokenContractAddress: Token.contractAddress.rawValue
        )
    }
}
