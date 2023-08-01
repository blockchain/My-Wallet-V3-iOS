import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import FeatureStakingDomain
import Foundation
import SwiftUI

struct EarnProductCompareView: View {

    typealias Action = EarnProductCompare.Action

    enum EarnProductItem: String, Identifiable {
        var id: String { rawValue }

        case userLevel
        case assets
        case rate
        case periodicity
        case payment
        case withdrawal
    }

    @Environment (\.openURL) var openURL
    let store: StoreOf<EarnProductCompare>
    let viewStore: ViewStoreOf<EarnProductCompare>

    @BlockchainApp var app
    @State var learnMoreUrl: URL?

    init(store: StoreOf<EarnProductCompare>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    @ViewBuilder
    var body: some View {
        VStack {
            ZStack {
                Text(Localization.Earn.Compare.title)
                    .typography(.body2)
                HStack(alignment: .center) {
                    Spacer()
                    Button {
                        viewStore.send(.onDismiss)
                    } label: {
                        Icon.navigationCloseButton()
                    }
                    .frame(width: 24, height: 24)
                }
                .padding(.horizontal, Spacing.padding3)
            }
            .padding(.top, Spacing.padding2)
            ZStack {
                carouselContentSection()
                buttonsSection()
            }
        }
        .background(Color.semantic.light.ignoresSafeArea())
        .onAppear {
            $app.post(event: blockchain.ux.earn.compare.products)
        }
        .bindings {
            subscribe($learnMoreUrl, to: blockchain.ux.earn.compare.products.learn.more.url)
        }
    }

    @ViewBuilder
    private func carouselContentSection() -> some View {
        TabView(selection: viewStore.binding(get: \.currentStep, send: Action.didChangeStep)) {
            ForEach(viewStore.steps) { step in
                VStack {
                    step.compareView(viewStore: viewStore)
                    Spacer()
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }

    @ViewBuilder
    private func buttonsSection() -> some View {
        VStack(spacing: .zero) {
            Spacer()
            PageControl(
                controls: viewStore.steps,
                selection: viewStore.binding(
                    get: \.currentStep,
                    send: { .didChangeStep($0) }
                )
            )
            PrimaryWhiteButton(
                title: Localization.Staking.learnMore,
                action: {
                    if let learnMoreUrl {
                        openURL(learnMoreUrl)
                    }
                }
            )
            .disabled(learnMoreUrl.isNil)
            .padding(.bottom, Spacing.padding3)
        }
        .padding(.horizontal, Spacing.padding3)
        .opacity(viewStore.gradientBackgroundOpacity)
    }
}

extension EarnProductCompare.State.Step {

    private var title: String {
        switch self {
        case .staking:
            return L10n.staking
        case .passive:
            return L10n.passive
        case .active:
            return L10n.active
        }
    }

    @ViewBuilder
    private var header: some View {
        HStack(alignment: .center, spacing: Spacing.padding2) {
            icon
            VStack(alignment: .leading, spacing: Spacing.baseline / 2) {
                Text(L10n.rewards.interpolating(title))
                    .typography(.body2)
                Text(subtitle)
                    .typography(.caption1)
                    .foregroundColor(.semantic.text)
            }
            Spacer()
        }
        .padding(Spacing.padding2)
        .background(
            RoundedRectangle(cornerRadius: Spacing.containerBorderRadius)
                .fill(Color.semantic.ultraLight)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.containerBorderRadius)
                .stroke(Color.semantic.silver)
        )
    }

    @ViewBuilder
    fileprivate func compareView(viewStore: ViewStoreOf<EarnProductCompare>) -> some View {
        VStack {
            header
            VStack(alignment: .center,spacing: Spacing.padding4) {
                ForEach(items) { item in
                    item.makeView(for: self, viewStore: viewStore)
                }
            }
            .padding(
                EdgeInsets(
                    top: Spacing.padding1,
                    leading: 0,
                    bottom: Spacing.padding4,
                    trailing: 0
                )
            )
        }
        .background(
            RoundedRectangle(cornerRadius: Spacing.containerBorderRadius)
                .fill(
                    Color.semantic.background
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.containerBorderRadius)
                .stroke(Color.semantic.silver)
        )
        .padding([.leading, .bottom, .trailing], Spacing.padding3)
        .padding(.top, Spacing.padding1)
    }

    @ViewBuilder
    private var icon: some View {
        switch self {
        case .passive:
            Icon
                .interest
                .color(.white)
                .circle(backgroundColor: Color.semantic.primary)
                .frame(width: 24, height: 24)
        case .staking:
            Icon
                .lockClosed
                .color(.semantic.primary)
                .frame(width: 20, height: 20)
        case .active:
            Icon
                .superAppPricesFilled
                .color(.semantic.primary)
                .frame(width: 20, height: 20)
        }
    }

    private var subtitle: String {
        switch self {
        case .passive:
            return Localization.Earn.Compare.Passive.description
        case .staking:
            return Localization.Earn.Compare.Staking.description
        case .active:
            return Localization.Earn.Compare.Active.description
        }
    }

    private var items: [EarnProductCompareView.EarnProductItem] {
        [.userLevel, .assets, .rate, .periodicity, .payment, .withdrawal]
    }
}

extension EarnProductCompareView.EarnProductItem {

    @ViewBuilder
    fileprivate func makeView(
        for step: EarnProductCompare.State.Step,
        viewStore: ViewStoreOf<EarnProductCompare>
    ) -> some View {
        HStack {
            icon
                .renderingMode(.template)
                .foregroundColor(.semantic.primary)
            VStack(alignment: .leading) {
                Text(title(for: step, viewStore: viewStore))
                    .typography(.paragraph2)
                if let description = description(for: step) {
                    Text(description)
                        .typography(.caption1)
                        .foregroundColor(.semantic.text)
                }
            }
            Spacer()
        }
        .padding(.horizontal, Spacing.padding2)
    }

    private var icon: Image {
        switch self {
        case .userLevel:
            return Image("Users", bundle: .featureStaking)
        case .assets:
            return Image("Coins", bundle: .featureStaking)
        case .rate:
            return Image("Rewards", bundle: .featureStaking)
        case .periodicity:
            return Image("USD", bundle: .featureStaking)
        case .payment:
            return Image("Wallet", bundle: .featureStaking)
        case .withdrawal:
            return Image("Send", bundle: .featureStaking)
        }
    }

    private func title(
        for step: EarnProductCompare.State.Step,
        viewStore: ViewStoreOf<EarnProductCompare>
    ) -> String {
        typealias L10n = Localization.Earn.Compare
        switch step {
        case .passive:
            typealias Items = L10n.Passive.Items
            switch self {
            case .userLevel:
                return Items.users
            case .assets:
                return Items.assets
            case .rate:
                let rate = viewStore.state.highestRate(for: .savings)
                return L10n.upToRateAnually(rate.formatted(.percent))
            case .periodicity:
                return Items.periodicity
            case .payment:
                return Items.payment
            case .withdrawal:
                return Items.withdrawal
            }
        case .staking:
            typealias Items = L10n.Staking.Items
            switch self {
            case .userLevel:
                return Items.users
            case .assets:
                return Items.assets
            case .rate:
                let rate = viewStore.state.highestRate(for: .staking)
                return L10n.upToRateAnually(rate.formatted(.percent))
            case .periodicity:
                return Items.periodicity
            case .payment:
                return Items.payment
            case .withdrawal:
                return Items.withdrawal
            }
        case .active:
            typealias Items = L10n.Active.Items
            switch self {
            case .userLevel:
                return Items.users
            case .assets:
                return Items.assets
            case .rate:
                let rate = viewStore.state.highestRate(for: .active)
                return L10n.upToRateAnually(rate.formatted(.percent))
            case .periodicity:
                return Items.periodicity
            case .payment:
                return Items.payment
            case .withdrawal:
                return Items.withdrawal
            }
        }
    }

    private func description(for step: EarnProductCompare.State.Step) -> String? {
        typealias L10n = Localization.Earn.Compare

        guard case .rate = self else {
            return nil
        }

        switch step {
        case .active:
            return L10n.Active.Items.rateDescription
        case .passive:
            return L10n.Passive.Items.rateDescription
        case .staking:
            return L10n.Staking.Items.rateDescription
        }
    }
}

struct EarnProductCompare_Previews: PreviewProvider {

    static var previews: some View {
        EarnProductCompareView(
            store: store
        )
        .app(App.preview)
    }

    static var store: StoreOf<EarnProductCompare> {
        Store(
            initialState: EarnProductCompare.State(
                products: products,
                model: models
            ),
            reducer: EarnProductCompare(
                onDismiss: {}
            )
        )
    }

    static let products: [EarnProduct] = [.savings, .staking, .active]

    static var models: [Model] {
        products.enumerated().map { idx, product -> Model in
            Model(
                product: product,
                asset: .bitcoin,
                marketCap: 0,
                isEligible: false,
                crypto: nil,
                fiat: nil,
                rate: Double(0.0355) * Double(idx + 1)
            )
        }
    }
}
