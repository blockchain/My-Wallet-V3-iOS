//
//  Token.swift
//  ERC20Kit
//
//  Created by Jack on 15/04/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit


// TODO:
// * document
public protocol Token {
    associatedtype AccountDetails: AssetAccountDetails
    
    static var details: AccountDetails.Type { get }
}


//import RxSwift
//import PlatformKit
import EthereumKit

public struct PaxToken: Token {
    
    
    
}
