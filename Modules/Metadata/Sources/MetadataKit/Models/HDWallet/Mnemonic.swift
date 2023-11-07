// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MetadataHDWalletKit
import ToolKit

public enum MnemonicError: LocalizedError, Equatable {
    case invalidLength
    case invalidWords

    public var errorDescription: String? {
        switch self {
        case .invalidLength:
            "Mnemonic Failure: invalid length"
        case .invalidWords:
            "Mnemonic Failure: invalid words"
        }
    }
}

struct Mnemonic {

    let mnemonicString: String

    let seedHex: String

    let words: [String]

    private init(
        words: [String],
        mnemonicString: String,
        seedHex: String
    ) {
        self.words = words
        self.mnemonicString = mnemonicString
        self.seedHex = seedHex
    }

    static func from(mnemonicString: String) -> Result<Self, MnemonicError> {

        func words(
            from mnemonicString: String
        ) -> Result<[String], MnemonicError> {

            let words = mnemonicString
                .lowercased()
                .components(separatedBy: " ")

            guard words.count == 12 else {
                return .failure(.invalidLength)
            }

            // For now we only support the english wordlist
            let BIP39Words = Set(MetadataHDWalletKit.WordList.english.words)

            guard Set(words).isSubset(of: BIP39Words) else {
                return .failure(.invalidWords)
            }

            return .success(words)
        }

        return words(from: mnemonicString)
            .map { words -> Mnemonic in
                let seedHex = MetadataHDWalletKit.Mnemonic
                    .createSeed(
                        mnemonic: mnemonicString
                    )
                    .hex
                return Mnemonic(
                    words: words,
                    mnemonicString: mnemonicString,
                    seedHex: seedHex
                )
            }
    }
}
