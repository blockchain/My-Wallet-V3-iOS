//
//  CryptoAssetQRMetadataFactory.swift
//  PlatformKit
//
//  Created by Chris Arriola on 5/17/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

/// Protocol definition for an abstract factory of `CryptoAssetQRMetadata`
public protocol CryptoAssetQRMetadataFactory {
    associatedtype Metadata: CryptoAssetQRMetadata
    associatedtype Account: WalletAccount

    func create(from account: Account) -> Metadata?
}

public final class AnyCryptoAssetQRMetadataFactory<M: CryptoAssetQRMetadata, A: WalletAccount>: CryptoAssetQRMetadataFactory {
    private let createClosure: (A) -> M?

    public func create(from account: A) -> M? {
        return createClosure(account)
    }

    public init<F: CryptoAssetQRMetadataFactory>(factory: F) where F.Metadata == Metadata, F.Account == Account {
        self.createClosure = factory.create
    }
}
