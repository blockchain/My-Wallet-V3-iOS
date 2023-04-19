import BlockchainComponentLibrary
import BlockchainNamespace
import BlockchainUI
import DIKit
import FeatureReceiveDomain
import FeatureTransactionDomain
import PlatformKit
import SwiftUI

struct AccountInfo: Identifiable, Hashable, Equatable {
    var id: AnyHashable {
        identifier
    }

    let identifier: AnyHashable
    let name: String
    let currency: CryptoCurrency
    let network: EVMNetwork?

    var filterTerm: String {
        name + " " + currency.code + " " + (network?.networkConfig.shortName ?? "")
    }
}

@MainActor
public struct ReceiveEntryView: View {

    typealias L10n = LocalizationConstants.ReceiveScreen.ReceiveEntry

    @BlockchainApp var app

    @State private var search: String = ""
    @State private var isSearching: Bool = false

    @StateObject private var model = Model()

    private let fuzzyAlgorithm = FuzzyAlgorithm()

    var filtered: [AccountInfo] {
        model.accounts.filter { account in
            search.isEmpty
            || account.name.distance(between: search, using: fuzzyAlgorithm) < 0.2
            || account.currency.name.distance(between: search, using: fuzzyAlgorithm) < 0.2
            || account.network?.networkConfig.shortName.distance(between: search, using: fuzzyAlgorithm) == 0.0
        }
    }

    public init() {}

    public var body: some View {
        content
            .superAppNavigationBar(
                title: {
                    Text(L10n.title)
                        .typography(.body2)
                        .foregroundColor(.semantic.title)
                },
                trailing: { close() },
                scrollOffset: nil
            )
            .onAppear {
                model.prepare(app: app)
            }
    }

    func close() -> some View {
        IconButton(
            icon: .closeCirclev3.small(),
            action: { $app.post(event: blockchain.ux.currency.receive.select.asset.article.plain.navigation.bar.button.close.tap) }
        )
        .batch {
            set(blockchain.ux.currency.receive.select.asset.article.plain.navigation.bar.button.close.tap.then.close, to: true)
        }
    }

    var content: some View {
        VStack {
            if model.accounts.isNotEmpty {
                SearchBar(
                    text: $search,
                    isFirstResponder: $isSearching.animation(),
                    cancelButtonText: L10n.cancel,
                    placeholder: L10n.search
                )
                .padding(.top, Spacing.padding2)
                .padding(.horizontal)
                list
            } else {
                Spacer()
                BlockchainProgressView()
                    .transition(.opacity)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.semantic.light.ignoresSafeArea())
    }

    @ViewBuilder var list: some View {
        List {
            if filtered.isEmpty {
                noResultsView
            } else {
                ForEach(filtered) { account in
                    ReceiveEntryRow(id: blockchain.ux.currency.receive.address.asset, account: account)
                        .context(
                            [
                                blockchain.coin.core.account.id: account.identifier,
                                blockchain.ux.currency.receive.address.asset.section.list.item.id: account.identifier
                            ]
                        )
                }
                .listRowInsets(.zero)
            }
        }
        .listStyle(.insetGrouped)
        .background(Color.semantic.light.ignoresSafeArea())
    }

    private var noResultsView: some View {
        HStack(alignment: .center, content: {
            Text(L10n.noResults)
                .padding(.vertical, Spacing.padding2)
        })
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

extension ReceiveEntryView {
    class Model: ObservableObject {

        private let accountProvider: ReceiveAccountProviding
        private let enabledCurrenciesService: EnabledCurrenciesServiceAPI

        @Published var accounts: [AccountInfo] = []

        init(
            accountProvider: @escaping ReceiveAccountProviding = ReceiveAccountProvider().accounts,
            enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()
        ) {
            self.accountProvider = accountProvider
            self.enabledCurrenciesService = enabledCurrenciesService
        }

        func prepare(app: AppProtocol) {
            app.modePublisher()
                .flatMapLatest { [accountProvider, enabledCurrenciesService] appMode -> AnyPublisher<[AccountInfo], Never> in
                    accountProvider(appMode)
                        .ignoreFailure(redirectsErrorTo: app)
                        .map { (accounts: [BlockchainAccount]) in
                            accounts.compactMap { account -> AccountInfo? in
                                guard let crypto = account.currencyType.cryptoCurrency else { return nil }
                                return AccountInfo(
                                    identifier: account.identifier,
                                    name: account.label,
                                    currency: crypto,
                                    network: enabledCurrenciesService.network(for: crypto)
                                )
                            }
                        }
                        .eraseToAnyPublisher()
                }
                .assign(to: &$accounts)
        }
    }
}

struct ReceiveEntryRow: View {

    @BlockchainApp var app

    let id: L & I_blockchain_ui_type_task
    let account: AccountInfo

    var body: some View {
        if #available(iOS 16.0, *) {
            content.alignmentGuide(.listRowSeparatorLeading) { d in d[.leading] }
        } else {
            content
        }
    }

    var content: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ZStack(alignment: .bottomTrailing) {
                    iconView(for: account)
                }
                Spacer()
                    .frame(width: 16)
                VStack(alignment: .leading, spacing: Spacing.textSpacing) {
                    Text(account.currency.name)
                        .typography(.paragraph2)
                        .foregroundColor(.semantic.title)
                    HStack(spacing: Spacing.textSpacing) {
                        Text(app.currentMode == .pkw ? account.name : account.currency.code.uppercased())
                            .typography(.caption1)
                            .foregroundColor(.semantic.text)
                        if let network = account.network?.networkConfig.shortName, network.isNotEmpty {
                            TagView(text: network, variant: .outline)
                        }
                    }
                }
                Spacer()
                Icon.chevronRight
                    .micro()
                    .iconColor(.semantic.text)
            }
        }
        .padding(Spacing.padding2)
        .background(Color.semantic.background)
        .onTapGesture {
            $app.post(
                event: id.paragraph.row.tap,
                context: [
                    blockchain.ux.asset.id: account.currency.code,
                    blockchain.ux.asset.account.id: account.identifier,
                    blockchain.ui.type.action.then.enter.into.embed.in.navigation: false
                ]
            )
        }
        .batch {
            set(id.paragraph.row.tap.then.enter.into, to: blockchain.ux.currency.receive.address)
        }
    }

    @ViewBuilder
    func iconView(for info: AccountInfo) -> some View {
        if #available(iOS 15.0, *) {
            ZStack(alignment: .bottomTrailing) {
                AsyncMedia(url: info.currency.assetModel.logoPngUrl, placeholder: { EmptyView() })
                    .frame(width: 24.pt, height: 24.pt)
                    .background(Color.WalletSemantic.light, in: Circle())

                if let network = info.network,
                    info.currency.code != network.nativeAsset.code
                {
                    ZStack(alignment: .center) {
                        AsyncMedia(url: network.nativeAsset.assetModel.logoPngUrl, placeholder: { EmptyView() })
                            .frame(width: 12.pt, height: 12.pt)
                            .background(Color.WalletSemantic.background, in: Circle())
                        Circle()
                            .strokeBorder(Color.WalletSemantic.background, lineWidth: 1)
                            .frame(width: 13, height: 13)
                    }
                    .offset(x: 4, y: 4)
                }
            }
        } else {
            EmptyView()
        }
    }
}
