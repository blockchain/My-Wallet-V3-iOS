// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import Combine
import Extensions
import MoneyKit
import SwiftUI

public enum Network: Codable, Equatable, Hashable, Identifiable {
    case all
    case specific(EVMNetwork)

    public var id: String {
        switch self {
        case .all:
            return "all"
        case .specific(let network):
            return network.networkConfig.networkTicker
        }
    }

    public var title: String {
        switch self {
        case .all:
            return L10n.NetworkPicker.allNetworks
        case .specific(let network):
            return network.networkConfig.shortName
        }
    }

    public var evmNetwork: EVMNetwork? {
        switch self {
        case .all:
            return nil
        case .specific(let network):
            return network
        }
    }
}

struct NetworkPickerButton: View {
    @BlockchainApp var app

    @State var currentNetwork: Network = .all

    @ViewBuilder
    var body: some View {
        Button {
            $app.post(
                event: blockchain.ux.nft.network.picker.entry.paragraph.button.primary.tap,
                context: [
                    blockchain.ux.nft.network.picker.selected.network: currentNetwork,
                    blockchain.ui.type.action.then.enter.into.embed.in.navigation: false,
                    blockchain.ui.type.action.then.enter.into.grabber.visible: true,
                    blockchain.ui.type.action.then.enter.into.detents: [
                        blockchain.ui.type.action.then.enter.into.detents.automatic.dimension
                    ]
                ]
            )
        } label: {
            HStack(spacing: Spacing.padding1) {
                if let evm = currentNetwork.evmNetwork {
                    evm.logoResource.image
                        .frame(width: 24.pt, height: 24.pt)
                } else {
                    Icon
                        .network
                        .small()
                        .color(.semantic.title)
                        .circle(backgroundColor: .semantic.light)
                }

                Text(L10n.NetworkPicker.title)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.title)

                Spacer()

                Text(currentNetwork.title)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.body)

                Icon
                    .chevronDown
                    .micro()
                    .color(.semantic.body)
                    .padding(.horizontal, Spacing.padding1)
            }
            .padding(Spacing.padding2)
            .background(Color.semantic.background)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.padding1, style: .continuous))
        }
        .batch {
            set(
                blockchain.ux.nft.network.picker.entry.paragraph.button.primary.tap.then.enter.into,
                to: blockchain.ux.nft.network.picker
            )
        }
        .bindings {
            subscribe($currentNetwork, to: blockchain.ux.nft.network.picker.selected.network)
        }
    }
}

struct NetworkPickerView: View {
    @BlockchainApp var app

    @StateObject var model = Model()

    var body: some View {
        VStack(spacing: Spacing.padding2) {
            header
                .padding(.top, Spacing.padding2)
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(model.availableNetworks) { network in
                        TableRow(
                            leading: {
                                if let evm = network.evmNetwork {
                                    evm.logoResource.image
                                        .frame(width: 24.pt, height: 24.pt)
                                } else {
                                    Icon
                                        .network
                                        .small()
                                        .color(.semantic.title)
                                        .circle(backgroundColor: .semantic.light)
                                }
                            },
                            title: network.title,
                            trailing: {
                                if model.selectedNetwork == network {
                                    Icon.check
                                        .small()
                                        .color(.semantic.primary)
                                }
                            }
                        )
                        .background(Color.semantic.background)
                        .onTapGesture {
                            Task { @MainActor [app] in
                                try await app.set(
                                    blockchain.ux.nft.network.picker.selected.network,
                                    to: network
                                )
                                app.post(event: blockchain.ux.nft.network.picker.entry.paragraph.button.icon.tap)
                            }
                        }
                    }
                }
                .cornerRadius(16, corners: .allCorners)
                .padding(.horizontal, Spacing.padding2)
            }
            .padding(.top, Spacing.padding1)
        }
        .onAppear {
            model.prepare(app: app)
        }
        .background(Color.semantic.light.ignoresSafeArea())
        .batch {
            set(blockchain.ux.nft.network.picker.entry.paragraph.button.icon.tap.then.close, to: true)
        }
    }

    @ViewBuilder
    var header: some View {
        HStack(spacing: Spacing.padding2) {
            Text(L10n.NetworkPicker.selectNetwork)
                .typography(.body2)
                .foregroundColor(.semantic.title)
            Spacer()
            IconButton(icon: .navigationCloseButton()) {
                app.post(event: blockchain.ux.nft.network.picker.entry.paragraph.button.icon.tap)
            }
            .frame(width: 20, height: 20)
        }
        .padding(.horizontal, Spacing.padding2)
    }
}

extension NetworkPickerView {
    class Model: ObservableObject {

        @Published var availableNetworks: [Network] = []
        @Published var selectedNetwork: Network = .all

        private let enabledCurrencies: EnabledCurrenciesServiceAPI

        init(
            enabledCurrencies: EnabledCurrenciesServiceAPI = EnabledCurrenciesService.default
        ) {
            self.enabledCurrencies = enabledCurrencies
        }

        func prepare(app: AppProtocol) {
            let networks = enabledCurrencies.allEnabledEVMNetworks
                .map { network -> Network in
                    .specific(network)
                }

            availableNetworks = [Network.all] + networks

            app.publisher(for: blockchain.ux.nft.network.picker.selected.network, as: Network.self)
                .compactMap(\.value)
                .receive(on: DispatchQueue.main)
                .assign(to: &$selectedNetwork)
        }
    }
}
