//
//  SendExchangeAddressStatePresenter.swift
//  Blockchain
//
//  Created by Daniel Huri on 30/09/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import ToolKit

@objc
final class SendExchangeAddressStatePresenter: NSObject {

    // MARK: - Types
    
    /// When fetching a Exchange address, we eitehr get a destination address or an error is thrown.
    /// In the event of an error, we're assuming this is because 2FA isn't enabled.
    enum ExchangeAddressResult {
        case destination(String)
        case twoFactorRequired
        
        var address: String? {
            switch self {
            case .destination(let output):
                return output
            case .twoFactorRequired:
                return nil
            }
        }
        
        var is2FARequired: Bool {
            switch self {
            case .twoFactorRequired:
                return true
            case .destination:
                return false
            }
        }
    }
    
    // MARK: - Properties
    
    var viewModel: Single<ExchangeAddressViewModel> {
        let model = ExchangeAddressViewModel(cryptoCurrency: assetType)
        return Single
            .zip(destinationAddress, isExchangeLinked)
            .map { addressResult, isLinked in
                model.isTwoFactorEnabled = !addressResult.is2FARequired
                model.address = addressResult.address
                model.isExchangeLinked = isLinked
                return model
        }
    }
    
    private var isExchangeLinked: Single<Bool> {
        blockchainRepository.fetchNabuUser().map {
            $0.hasLinkedExchangeAccount
        }
    }
    
    private var destinationAddress: Single<ExchangeAddressResult> {
        exchangeAddressFetcher.fetchAddress(for: assetType)
            .map { .destination($0) }
            .catchError { error -> Single<ExchangeAddressResult> in
                switch error {
                case ExchangeAddressFetcher.FetchingError.twoFactorRequired:
                    return .just(.twoFactorRequired)
                default:
                    throw error
                }
            }
    }
    
    private let exchangeAddressFetcher: ExchangeAddressFetching
    private let disposeBag = DisposeBag()
    private let assetType: CryptoCurrency
    private let blockchainRepository: BlockchainDataRepository
    
    init(assetType: CryptoCurrency,
         exchangeAddressFetcher: ExchangeAddressFetching = ExchangeAddressFetcher(),
         blockchainRepository: BlockchainDataRepository = BlockchainDataRepository.shared) {
        self.assetType = assetType
        self.exchangeAddressFetcher = exchangeAddressFetcher
        self.blockchainRepository = blockchainRepository
    }
    
    // MARK: - Legacy (to be used only inside the ObjC code base)
    
    @objc
    init(assetType: LegacyAssetType) {
        self.assetType = CryptoCurrency(legacyAssetType: assetType)
        self.exchangeAddressFetcher = ExchangeAddressFetcher()
        self.blockchainRepository = BlockchainDataRepository.shared
    }
    
    @objc
    func fetchAddressViewModel(completion: @escaping (ExchangeAddressViewModel) -> Void) {
        viewModel.observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { model in
                completion(model)
            }, onError: { error in
                Logger.shared.error(error)
            })
            .disposed(by: disposeBag)
    }
}
