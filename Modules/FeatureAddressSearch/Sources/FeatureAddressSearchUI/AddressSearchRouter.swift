// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import DIKit
import Extensions
import FeatureAddressSearchDomain
import Foundation
import SwiftUI

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
