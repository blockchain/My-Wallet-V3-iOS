//
//  LegacyEthereumWalletAPI.swift
//  Blockchain
//
//  Created by Jack on 07/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

public protocol LegacyEthereumWalletAPI: class {
    
    func checkIfEthereumAccountExists() -> Bool
    
    func ethereumAccounts(with secondPassword: String?, success: @escaping ([[String: Any]]) -> Void, error: @escaping (String) -> Void)
    func getLabelForEthereumAccount(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void)
    func getEthereumAddress(with secondPassword: String?, success: @escaping (String) -> Void, error: @escaping (String) -> Void)

    func getEthereumMemo(for transaction: String, success: @escaping (String?) -> Void, error: @escaping (String) -> Void) 
    func setEthereumMemo(for transaction: String, memo: String?)
                
    func erc20Tokens(with secondPassword: String?, success: @escaping ([String: [String: Any]]) -> Void, error: @escaping (String) -> Void)
    func saveERC20Tokens(with secondPassword: String?, tokensJSONString: String, success: @escaping () -> Void, error: @escaping (String) -> Void)

    func recordLastEthereumTransaction(transactionHash: String, success: @escaping () -> Void, error: @escaping (String) -> Void)
}
