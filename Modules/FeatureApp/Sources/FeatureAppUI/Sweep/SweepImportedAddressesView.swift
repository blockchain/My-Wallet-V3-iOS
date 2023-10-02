// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import Blockchain
import BlockchainComponentLibrary
import BlockchainUI
import Combine
import Dependencies
import DIKit
import Extensions
import Localization
import SwiftUI

struct SweepImportedAddressesView: View {
    typealias L10n = LocalizationConstants.SweepImportedAddress

    @BlockchainApp var app

    @StateObject var model = Model()

    @State private var currency: CryptoCurrency?

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Text(L10n.notice)
                    .typography(.paragraph1)
                    .foregroundColor(.semantic.title)
                    .padding(.horizontal, Spacing.padding2)
                if !model.accounts.isEmpty {
                    List {
                        ForEach($model.accounts.animation(), id: \.self) { account in
                            ImportedAddressRow(model: account, sweepState: $model.accountsSend[account.id].animation())
                                .listRowSeparatorTint(Color.semantic.light)
                                .context(
                                    [
                                        blockchain.coin.core.account.id: account.id
                                    ]
                                )
                        }
                        .opacity(model.sweepCompletion != .none ? 0.5 : 1.0)
                        .listRowInsets(.zero)
                    }
                    .hideScrollContentBackground()
                    .listStyle(.insetGrouped)
                    .safeAreaInset(edge: .bottom) {
                        VStack {
                            if model.sweepCompletion != .none {
                                completionState()
                            } else {
                                PrimaryButton(title: L10n.transferFunds, isLoading: model.sweeping) {
                                    model.performSweep()
                                }
                                .disabled(model.accounts.isEmpty)
                                .padding(.horizontal, Spacing.padding2)
                                .padding(.bottom, Spacing.padding2)
                            }
                        }
                        .padding(.top, Spacing.padding1)
                        .background(Color.semantic.light.ignoresSafeArea())
                    }
                } else {
                    loadingView()
                }
            }
            .background(Color.semantic.light)
        }
        .superAppNavigationBar(
            title: {
                Text(L10n.title)
                    .typography(.body2)
                    .foregroundColor(.semantic.title)
            },
            trailing: {
                close
            },
            scrollOffset: nil
        )
        .frame(maxWidth: .infinity)
        .background(Color.semantic.light.ignoresSafeArea())
        .onAppear {
            model.prepare()
        }
        .bindings {
            subscribe($currency.animation(), to: blockchain.coin.core.account.currency)
        }
        .navigationBarHidden(true)
    }

    var close: some View {
        IconButton(
            icon: .close
                .circle()
                .small(),
            action: {
                $app.post(event: blockchain.ux.sweep.imported.addresses.transfer.article.plain.navigation.bar.button.close.tap)
            }
        )
            .batch {
                set(blockchain.ux.sweep.imported.addresses.transfer.article.plain.navigation.bar.button.close.tap.then.close, to: true)
            }
        }

    @ViewBuilder
    func loadingView() -> some View {
        Spacer()
        BlockchainProgressView()
            .transition(.opacity)
        Spacer()
    }

    @ViewBuilder
    func completionState() -> some View {
        VStack(alignment: .center, spacing: Spacing.padding2) {
            AlertCard(
                title: model.sweepCompletion == .finished ? L10n.success : L10n.failure,
                message: model.sweepCompletion == .finished ? L10n.successNotice : L10n.failureNotice,
                variant: model.sweepCompletion == .finished ? .success : .error,
                isBordered: true
            )
            PrimaryButton(title: L10n.okButton) {
                $app.post(event: blockchain.ux.sweep.imported.addresses.transfer.article.plain.navigation.bar.button.close.tap)
            }
        }
        .background(Color.semantic.light.ignoresSafeArea())
        .padding(.horizontal, Spacing.padding2)
        .padding(.bottom, Spacing.padding2)
        .batch {
            set(blockchain.ux.sweep.imported.addresses.transfer.article.plain.navigation.bar.button.close.tap.then.close, to: true)
        }
    }
}

struct ImportedAddressRow: View {
    @Environment(\.context) var context
    @Environment(\.coincore) var coincore

    @BlockchainApp var app

    @Binding var model: SweepModel

    @Binding var sweepState: SweepModel.State?

    @State private var address: String?
    @State private var balance: MoneyValue?
    @State private var exchangeRate: MoneyValue?

    var addressFormatted: String? {
        address?.obfuscate(keeping: 4)
    }

    var currency: CryptoCurrency? {
        balance?.currency.cryptoCurrency
    }

    var price: MoneyValue? {
        guard let balance, let exchangeRate else { return nil }
        return balance.convert(using: exchangeRate)
    }

    var body: some View {
        if #available(iOS 16.0, *) {
            content.alignmentGuide(.listRowSeparatorLeading) { d in d[.leading] }
        } else {
            content
        }
    }

    @ViewBuilder
    var content: some View {
        if balance == nil || currency != nil {
            VStack(spacing: 0) {
                if let currency {
                    HStack(spacing: 0) {
                        currency.logo(size: 24.pt)
                        Spacer()
                            .frame(width: 16)

                        VStack(alignment: .leading, spacing: 4.pt) {
                            Text(model.label.isEmpty ? currency.name : model.label)
                                .typography(.paragraph2)
                                .foregroundColor(.semantic.title)
                            if let addressFormatted {
                                Text(addressFormatted)
                                    .typography(.caption1)
                                    .foregroundColor(.semantic.body)
                            }
                        }

                        Spacer()
                        if let sweepState, sweepState != .none {
                            VStack(alignment: .center) {
                                if sweepState == .success {
                                    Icon.check
                                        .small()
                                        .color(.semantic.success)
                                } else {
                                    Icon.close
                                        .small()
                                        .color(.semantic.error)
                                }
                            }
                            .transition(.opacity)
                        } else {
                            VStack(alignment: .trailing, spacing: 4.pt) {
                                Group {
                                    if let price, price.isPositive {
                                        Text(price.toDisplayString(includeSymbol: true))
                                    } else if balance == nil {
                                        Text("..........").redacted(reason: .placeholder)
                                    }
                                }
                                .typography(.paragraph2.slashedZero())
                                .foregroundColor(.semantic.title)
                                Group {
                                    if let balance {
                                        Text(balance.toDisplayString(includeSymbol: true))
                                    } else {
                                        Text("..........").redacted(reason: .placeholder)
                                    }
                                }
                                .typography(.caption1.slashedZero())
                                .foregroundColor(.semantic.body)
                            }
                            .transition(.opacity)
                        }
                    }
                }
            }
            .navigationBarHidden(false)
            .padding(Spacing.padding2)
            .background(Color.semantic.background)
            .bindings {
                subscribe($address, to: blockchain.coin.core.account.receive.address)
                subscribe($balance, to: blockchain.coin.core.account.balance.available)
            }
            .bindings {
                if let currency {
                    subscribe($exchangeRate, to: blockchain.api.nabu.gateway.price.crypto[currency.code].fiat.quote.value)
                }
            }
        } else {
            Text(model.account)
                .foregroundColor(.semantic.error)
                .typography(.caption1)
        }
    }
}

struct SweepModel: Identifiable, Hashable {
    enum State: Hashable {
        case none
        case success
        case failure
    }

    var id: String { account }

    var account: String
    var label: String

    var state: State
}

enum SweepCompletion {
    case none
    case finished
    case finishedWithErrors
    case failure
}

extension SweepImportedAddressesView {
    class Model: ObservableObject {

        @Dependency(\.app) var app
        @Dependency(\.sweepService) var sweepService

        @Published var accounts: [SweepModel] = []
        @Published var accountsSend: [String: SweepModel.State] = [:]
        @Published var sweepCompletion: SweepCompletion = .none
        @Published var sweeping: Bool = false

        private var bag: Set<AnyCancellable> = []

        func prepare() {

            sweepService.prepare(force: false)
                .map { accounts -> [SweepModel] in
                    accounts.map {
                        SweepModel(account: $0.identifier, label: $0.label, state: .none)
                    }
                }
                .receive(on: DispatchQueue.main)
                .replaceError(with: [])
                .assign(to: &$accounts)

            $sweepCompletion
                .sink { [app] completion in
                    switch completion {
                    case .none: break
                    case .finished:
                        app.post(event: blockchain.ux.sweep.imported.addresses.transfer.success)
                    case .failure,
                        .finishedWithErrors:
                        app.post(event: blockchain.ux.sweep.imported.addresses.transfer.failure)
                    }
                }
                .store(in: &bag)
        }

        func performSweep() {
            app.post(event: blockchain.ux.sweep.imported.addresses.transfer.perform)
            sweeping = true
            sweepService.performSweep()
                .receive(on: DispatchQueue.main)
                .catch { [weak self] _ in
                    self?.sweepCompletion = .failure
                    self?.sweeping = false
                    return []
                }
                .handleEvents(
                    receiveCompletion: { [weak self] completion in
                        guard let self else {
                            self?.sweeping = false
                            return
                        }
                        sweeping = false
                        if completion == .finished {
                            sweepCompletion = accountsSend.values.allSatisfy { $0 == .success } ? .finished : .finishedWithErrors
                        } else {
                            sweepCompletion = .failure
                        }
                    },
                    receiveCancel: { [weak self] in
                        self?.sweeping = false
                    }
                )
                .sink { [weak self] txResults in
                    if let last = txResults.last {
                        if let model = self?.accounts.first(where: { $0.account == last.accountIdentifier }) {
                            withAnimation {
                                self?.accountsSend[model.account] = last.result.isSuccess ? .success : .failure
                            }
                        }
                    }
                }
                .store(in: &bag)
        }
    }
}

private enum SweepImportedAddressesServiceKey: DependencyKey {
    static var liveValue: SweepImportedAddressesServiceAPI = DIKit.resolve()
}

extension DependencyValues {
  var sweepService: SweepImportedAddressesServiceAPI {
    get { self[SweepImportedAddressesServiceKey.self] }
    set { self[SweepImportedAddressesServiceKey.self] = newValue }
  }
}
