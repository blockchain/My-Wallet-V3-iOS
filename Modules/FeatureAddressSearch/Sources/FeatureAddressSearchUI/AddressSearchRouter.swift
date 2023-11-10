// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import DIKit
import Extensions
import FeatureAddressSearchDomain
import Foundation
import Localization
import SwiftUI

public final class AddressSearchBuilder {

    private let addressService: AddressServiceAPI
    private let addressSearchService: AddressSearchServiceAPI

    public init(
        addressService: AddressServiceAPI = NoOpAddressService(),
        addressSearchService: AddressSearchServiceAPI = resolve()
    ) {
        self.addressService = addressService
        self.addressSearchService = addressSearchService
    }

    @MainActor
    public func searchAddressView(
        prefill: Address? = nil,
        config: AddressSearchFeatureConfig = .default,
        onComplete: @escaping (AddressResult) -> Void
    ) -> some View {
        AddressSearchView(
            store: Store(
                initialState: .init(address: prefill, error: nil),
                reducer: { [addressService, addressSearchService] in
                    AddressSearchReducer(
                        mainQueue: .main,
                        config: config,
                        addressService: addressService,
                        addressSearchService: addressSearchService,
                        onComplete: onComplete
                    )
                }
            )
        )
    }
}

public final class NoOpAddressService: AddressServiceAPI {

    public init() {}

    public func fetchAddress() -> AnyPublisher<Address?, AddressServiceError> {
        .just(nil)
    }
    
    public func save(address: Address) -> AnyPublisher<Address, AddressServiceError> {
        .just(address)
    }
}

public final class AddressSearchRouter: AddressSearchRouterAPI {

    private let topMostViewControllerProvider: TopMostViewControllerProviding
    private let addressService: AddressServiceAPI

    public init(
        topMostViewControllerProvider: TopMostViewControllerProviding,
        addressService: AddressServiceAPI
    ) {
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.addressService = addressService
    }

    @MainActor
    public func presentSearchAddressFlow(
        prefill: Address?,
        config: AddressSearchFeatureConfig
    ) -> AnyPublisher<AddressResult, Never> {
        Deferred {
            Future { [weak self] promise in

                guard let self else { return }

                let presenter = topMostViewControllerProvider.topMostViewController
                let view = AddressSearchView(
                    store: Store(
                        initialState: .init(address: prefill, error: nil),
                        reducer: { [addressService] in
                            AddressSearchReducer(
                                mainQueue: .main,
                                config: config,
                                addressService: addressService,
                                addressSearchService: resolve(),
                                onComplete: { address in
                                    self.topMostViewControllerProvider
                                        .topMostViewController?
                                        .dismiss(animated: true) {
                                            promise(.success(address))
                                        }
                                }
                            )
                        }
                    )
                )
                presenter?.present(view)
            }
        }.eraseToAnyPublisher()
    }

    @MainActor
    public func presentEditAddressFlow(
        isPresentedFromSearchView: Bool,
        config: AddressSearchFeatureConfig.AddressEditScreenConfig
    ) -> AnyPublisher<AddressResult, Never> {
        Deferred {
            Future { [weak self] promise in

                guard let self else { return }

                let presenter = topMostViewControllerProvider.topMostViewController
                let view = AddressModificationView(
                    store: Store(
                        initialState: .init(isPresentedFromSearchView: isPresentedFromSearchView),
                        reducer: { [addressService] in
                            AddressModificationReducer(
                                mainQueue: .main,
                                config: config,
                                addressService: addressService,
                                addressSearchService: resolve(),
                                onComplete: { addressResult in
                                    presenter?.dismiss(animated: true) {
                                        promise(.success(addressResult))
                                    }
                                }
                            )
                        }
                    )
                )
                presenter?.present(view)
            }
        }.eraseToAnyPublisher()
    }

    @MainActor
    public func presentEditAddressFlow(
        address: Address,
        config: AddressSearchFeatureConfig.AddressEditScreenConfig
    ) -> AnyPublisher<AddressResult, Never> {
        Deferred {
            Future { [weak self] promise in

                guard let self else { return }

                let presenter = topMostViewControllerProvider.topMostViewController
                let view = AddressModificationView(
                    store: Store(
                        initialState: .init(address: address),
                        reducer: { [addressService] in
                            AddressModificationReducer(
                                mainQueue: .main,
                                config: config,
                                addressService: addressService,
                                addressSearchService: resolve(),
                                onComplete: { addressResult in
                                    presenter?.dismiss(animated: true) {
                                        promise(.success(addressResult))
                                    }
                                }
                            )
                        }
                    )
                )
                presenter?.present(view)
            }
        }.eraseToAnyPublisher()
    }
}

extension AddressSearchFeatureConfig {

    private typealias L10n = LocalizationConstants.AddressSearch.DefaultConfig

    public static let `default`: AddressSearchFeatureConfig = AddressSearchFeatureConfig(
        addressSearchScreen: AddressSearchScreenConfig(
            title: L10n.title,
            subtitle: L10n.subtitle
        ),
        addressEditScreen: AddressEditScreenConfig(
            title: L10n.title,
            saveAddressButtonTitle: L10n.nextButtonTitle
        )
    )
        
}
