import BlockchainComponentLibrary
import BlockchainUI
import CoreImage.CIFilterBuiltins
import DIKit
import FeatureTransactionDomain
import PlatformUIKit
import SwiftUI
import UIKit

@MainActor
public struct ReceiveAddressView: View {

    typealias L10n = LocalizationConstants.ReceiveScreen

    @BlockchainApp var app
    @Environment(\.context) var context

    @StateObject var model = Model()

    @State private var displayCopyAlert: Bool = false
    @State private var alertOnCopyText: String = ""

    @State private var currency: CryptoCurrency?
    @State private var scrollOffset: CGPoint = .zero
    @State private var assetIsDeFi: Bool = false

    @State private var showShareSheet: Bool = false

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                ScrollView {
                    VStack(spacing: Spacing.padding2) {
                        networkInformation
                        VStack(spacing: Spacing.padding2) {
                            networkWarning
                            qrCode
                            addressInfo
                        }
                        .redacted(reason: model.isLoading ? .placeholder : [])
                        .frame(minHeight: 300)
                        .padding(Spacing.padding1)
                        .background(
                            RoundedRectangle(cornerRadius: Spacing.padding2)
                                .fill(Color.semantic.background)
                        )
                    }
                    .scrollOffset($scrollOffset)
                    .padding(.horizontal, Spacing.padding2)
                    .padding(.top, Spacing.padding2)
                }
                Spacer()
                MinimalButton(title: L10n.ReceiveAddressScreen.copyAddressButton, foregroundColor: .semantic.title) {
                    Icon
                        .copy
                        .small()
                } action: {
                    $app.post(event: blockchain.ux.currency.receive.address.copy.address.entry.paragraph.button.minimal.tap)
                    displayCopiedAlert(text: L10n.ReceiveAddressScreen.addressCopied)
                }
                .batch {
                    if let address = model.address?.value {
                        set(blockchain.ux.currency.receive.address.copy.address.entry.paragraph.button.minimal.tap.then.copy, to: address)
                    }
                }
                .redacted(reason: model.isLoading ? .placeholder : [])
                .padding(.horizontal, Spacing.padding2)
                .padding(.bottom, Spacing.padding2)
            }

            if displayCopyAlert {
                AlertToast(text: alertOnCopyText)
                    .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                    .zIndex(1)
                    .offset(y: -Spacing.padding2)
            }
        }
        .superAppNavigationBar(
            leading: {
                IconButton(icon: .shareiOS.small().color(.semantic.title)) {
                    showShareSheet.toggle()
                }
            },
            title: {
                if let currency {
                    HStack(spacing: Spacing.padding1) {
                        AsyncMedia(url: currency.logoURL)
                            .frame(width: 24.pt, height: 24.pt)
                        Text(String(format: L10n.ReceiveAddressScreen.title, currency.name))
                            .typography(.body2)
                            .foregroundColor(.semantic.title)
                    }
                } else {
                    Text(L10n.ReceiveEntry.receive)
                        .typography(.body2)
                        .foregroundColor(.semantic.title)
                }
            },
            trailing: {
                close
            },
            scrollOffset: $scrollOffset.y
        )
        .sheet(
            isPresented: $showShareSheet,
            content: {
                if let address = model.address, let currency {
                    ActivityViewController(
                        activityItems: model.shareDetails(for: address.value, currencyType: currency.currencyType),
                        excludedActivityTypes: model.exludedActivities()
                    )
                } else {
                    EmptyView()
                }
            }
        )
        .frame(maxWidth: .infinity)
        .background(Color.semantic.light.ignoresSafeArea())
        .onAppear {
            model.prepare(app: app, context: context)
        }
        .bindings {
            subscribe($currency.animation(), to: blockchain.coin.core.account.currency)
        }
        .navigationBarHidden(true)
    }

    @ViewBuilder
    var qrCode: some View {
        ZStack(alignment: .center) {
            Image(uiImage: model.qrCode ?? UIImage())
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 312, height: 312)
            ProgressView()
                .opacity(model.isLoading ? 1.0 : 0.0)
                .redacted(reason: [])
        }
    }

    @ViewBuilder
    var networkInformation: some View {
        if let currency,
            let network = model.network,
            let name = network.name, name.isNotEmpty,
           currency.code != network.assetCurrency?.code
        {
            HStack(spacing: Spacing.padding1) {
                if let asset = network.assetCurrency {
                    AsyncMedia(url: asset.logoURL)
                        .frame(width: 24.pt, height: 24.pt)
                }
                Text(String(format: L10n.ReceiveAddressScreen.defiNetworkInformation, currency.name, name))
                    .typography(.caption2)
                    .foregroundColor(.semantic.body)
            }
            .padding(Spacing.padding1)
            .background(
                RoundedRectangle(cornerRadius: Spacing.padding2)
                    .fill(Color.semantic.background)
            )
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    var addressInfo: some View {
        VStack(spacing: Spacing.textSpacing) {
            if let domain = model.domain {
                Text(domain)
                    .typography(.body2)
                    .foregroundColor(.semantic.title)
                    .onTapGesture {
                        $app.post(event: blockchain.ux.currency.receive.address.copy.domain.entry.paragraph.button.minimal.tap)
                        displayCopiedAlert(text: L10n.ReceiveAddressScreen.domainCopied)
                    }
                    .batch {
                        set(blockchain.ux.currency.receive.address.copy.domain.entry.paragraph.button.minimal.tap.then.copy, to: domain)
                    }
            }
            Text(model.address?.value ?? "")
                .typography(.paragraph1)
                .foregroundColor(.semantic.body)
                .padding(.horizontal, 100)
                .lineLimit(1)
                .truncationMode(.middle)
                .onTapGesture {
                    $app.post(event: blockchain.ux.currency.receive.address.copy.address.entry.paragraph.button.minimal.tap)
                    displayCopiedAlert(text: L10n.ReceiveAddressScreen.addressCopied)
                }
                .batch {
                    if let address = model.address?.value {
                        set(blockchain.ux.currency.receive.address.copy.address.entry.paragraph.button.minimal.tap.then.copy, to: address)
                    }
                }
            if let memo = model.address?.memo {
                HStack(spacing: Spacing.textSpacing) {
                    Text(L10n.ReceiveAddressScreen.memo)
                        .typography(.caption1)
                    TagView(text: memo, variant: .default)
                }
            }
        }
        .padding(.bottom, Spacing.padding2)
    }

    @ViewBuilder
    var networkWarning: some View {
        if let network = model.network {
            if let name = network.name, name.isNotEmpty, let code = currency?.code {
                HStack(spacing: Spacing.textSpacing) {
                    Icon.alert.micro()
                        .iconColor(Color.semantic.warning)
                    Text(String(format: L10n.ReceiveAddressScreen.defiNetworkWarning, code, name))
                        .typography(.caption1)
                        .foregroundColor(.semantic.warning)
                }
                .padding(.top, Spacing.padding2)
            } else {
                EmptyView()
            }
        } else {
            EmptyView()
        }
    }

    var close: some View {
        IconButton(
            icon: .closeCirclev3.small(),
            action: { $app.post(event: blockchain.ux.currency.receive.address.article.plain.navigation.bar.button.close.tap) }
        )
        .batch {
            set(blockchain.ux.currency.receive.address.article.plain.navigation.bar.button.close.tap.then.close, to: true)
        }
    }

    func displayCopiedAlert(text: String) {
        withAnimation(.interpolatingSpring(stiffness: 170, damping: 15)) {
            alertOnCopyText = text
            displayCopyAlert = true
            withAnimation(.easeOut.delay(2)) {
                displayCopyAlert = false
            }
        }
    }
}

extension ReceiveAddressView {
    class Model: ObservableObject {
        struct ReceiveAddress: Equatable {
            let value: String
            let memo: String?
        }

        struct AssetNetwork: Decodable, Equatable {
            let name: String?
            let asset: String?

            var assetCurrency: CryptoCurrency? {
                guard let asset else {
                    return nil
                }
                return CryptoCurrency(code: asset)
            }
        }

        @Published var network: AssetNetwork?
        @Published var address: ReceiveAddress?
        @Published var domain: String?
        @Published var qrCode: UIImage?

        var isLoading: Bool {
            address.isNil
        }

        private let resolutionService: BlockchainNameResolutionServiceAPI
        private let qrCodeProvider: (_ string: String) -> UIImage?

        init(
            resolutionService: BlockchainNameResolutionServiceAPI = DIKit.resolve(),
            qrCodeProvider: @escaping (_ string: String) -> UIImage? = provideQRCode(for:)
        ) {
            self.resolutionService = resolutionService
            self.qrCodeProvider = qrCodeProvider
        }

        func prepare(app: AppProtocol, context: Tag.Context) {

            app.publisher(
                for: blockchain.coin.core.account.receive.address[].ref(to: context, in: app),
                as: L_blockchain_coin_core_account_receive.JSON.self
            )
            .zip(app.publisher(for: blockchain.coin.core.account[].ref(to: context, in: app), as: L_blockchain_coin_core_account.JSON.self))
            .map(\.0.value, \.1.value)
            .flatMapLatest { [resolutionService] address, account -> AnyPublisher<String?, Never> in
                guard let currency = account?.currency else {
                    return .just(nil)
                }
                guard let firstAddress = address?.first.address else {
                    return .just(nil)
                }
                return resolutionService.reverseResolve(address: firstAddress, currency: currency)
                    .replaceError(with: [])
                    .map(\.first)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$domain)

            app.publisher(
                for: blockchain.coin.core.account.receive.address[].ref(to: context, in: app),
                as: L_blockchain_coin_core_account_receive.JSON.self
            )
            .map(\.value)
            .receive(on: DispatchQueue.main)
            .map { [qrCodeProvider] value -> UIImage? in
                guard let content = value?.qr.metadata.content else {
                    return nil
                }
                return qrCodeProvider(content)
            }
            .assign(to: &$qrCode)

            app.publisher(
                for: blockchain.coin.core.account.receive.address[].ref(to: context, in: app),
                as: L_blockchain_coin_core_account_receive.JSON.self
            )
            .map(\.value)
            .receive(on: DispatchQueue.main)
            .map { value -> ReceiveAddress? in
                guard let content = value?.address else {
                    return nil
                }
                return ReceiveAddress(value: content, memo: value?.memo)
            }
            .assign(to: &$address)

            app.publisher(
                for: blockchain.coin.core.account[].ref(to: context, in: app),
                as: L_blockchain_coin_core_account.JSON.self
            )
            .map(\.value)
            .receive(on: DispatchQueue.main)
            .map { value -> AssetNetwork? in
                guard let value else {
                    return nil
                }
                return AssetNetwork(name: value.network.name, asset: value.network.asset)
            }
            .assign(to: &$network)
        }

        func shareDetails(for address: String, currencyType: CurrencyType) -> [Any] {
            let displayCode = currencyType.displayCode
            let prefix = String(format: L10n.ReceiveAddressScreen.pleaseSendXTo, displayCode)
            return ["\(prefix) \(address)"]
        }

        func exludedActivities() -> [UIActivity.ActivityType] {
            [
                .assignToContact,
                .addToReadingList,
                .postToFacebook,
                .postToVimeo,
                .postToWeibo,
                .postToFlickr,
                .postToTencentWeibo,
                .openInIBooks
            ]
        }
    }
}

private func provideQRCode(for string: String) -> UIImage? {
    let data = Data(string.utf8)
    let filter = CIFilter.qrCodeGenerator()
    filter.setDefaults()
    filter.message = data
    filter.correctionLevel = "M"
    guard let outputImage = filter.outputImage else {
        return nil
    }
    let context = CIContext()
    guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
        return nil
    }
    return UIImage(cgImage: cgImage)
}
