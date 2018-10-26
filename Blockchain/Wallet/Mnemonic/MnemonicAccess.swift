//
//  MnemonicAccess.swift
//  Blockchain
//
//  Created by Chris Arriola on 10/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// Typealias for a mnemonic phrase used to generate a public/private key pair
typealias Mnemonic = String

protocol MnemonicAccess {

    /// Returns a Maybe emmitting a Mnemonic if and only if the mnemonic is not double encrypted
    var mnemonic: Maybe<Mnemonic> { get }

    /// Returns a Maybe emitting a Mnemonic if and only if the user enters the correct second password
    /// in the presented prompt
    var mnemonicForcePrompt: Maybe<Mnemonic> { get }

    /// Returns a Maybe emitting a Mnemonic. This will prompt the user to enter the second password if needed.
    var mnemonicPromptingIfNeeded: Maybe<Mnemonic> { get }
}

extension MnemonicAccess {
    var mnemonicPromptingIfNeeded: Maybe<Mnemonic> {
        return mnemonic.ifEmpty(switchTo: mnemonicForcePrompt)
    }
}
