import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import FeatureStakingDomain
import Foundation
import Localization
import SwiftUI

public struct EarnProductCompareView: View {

    enum EarnProductItem: String, Identifiable {
        var id: String { rawValue }

        case userLevel
        case assets
        case rate
        case periodicity
        case payment
        case withdrawal
    }

    let store: StoreOf<EarnProductCompare>

    @BlockchainApp var app
    @State var learnMoreUrl: URL?

    public init(store: StoreOf<EarnProductCompare>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                ZStack {
                    Text(LocalizationConstants.Earn.Compare.title)
                        .typography(.body2)
                    HStack(alignment: .center) {
                        Spacer()
                        Button {
                            viewStore.send(.onDismiss)
                        } label: {
                            Icon.closeCirclev3
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
            .background(
                Color.semantic.light.ignoresSafeArea()
            )
            .onAppear {
                $app.post(event: blockchain.ux.earn.compare.products)
            }
        }
        .bindings {
            subscribe($learnMoreUrl, to: blockchain.ux.earn.compare.products.learn.more.url)
        }
    }

    @ViewBuilder private func carouselContentSection() -> some View {
        WithViewStore(store) { viewStore in
            #if os(iOS)
            TabView(
                selection: viewStore.binding(
                    get: { $0.currentStep },
                    send: { .didChangeStep($0) }
                )
            ) {
                ForEach(viewStore.steps) { step in
                    VStack {
                        step.makeCompareView()
                        Spacer()
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            #else
            TabView(
                selection: viewStore.binding(
                    get: { $0.currentStep },
                    send: { .didChangeStep($0) }
                )
            ) {
                ForEach(viewStore.steps) { step in
                    step.makeView()
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            #endif
        }
    }

    @ViewBuilder private func buttonsSection() -> some View {
        WithViewStore(store) { viewStore in
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
                    title: LocalizationConstants.Staking.learnMore,
                    action: {
                        viewStore.send(.openUrl(learnMoreUrl))
                    }
                )
                .disabled(learnMoreUrl == .none)
                .padding(.bottom, Spacing.padding3)
            }
            .padding(.horizontal, Spacing.padding3)
            .opacity(viewStore.gradientBackgroundOpacity)
        }
    }
}

extension EarnProductCompare.State.Step {

    var title: String {
        switch self {
        case .staking: return L10n.staking
        case .passive: return L10n.passive
        case .active: return L10n.active
        }
    }

    @ViewBuilder fileprivate var header: some View {
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
                .fill(
                    Color.semantic.ultraLight
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: Spacing.containerBorderRadius)
                .stroke(Color.semantic.silver)
        )
    }

    @ViewBuilder fileprivate func makeCompareView() -> some View {
        VStack {
            header
            VStack(
                alignment: .center,
                spacing: Spacing.padding4
            ) {
                ForEach(items) { item in
                    item.makeView(for: self)
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

    @ViewBuilder fileprivate var icon: some View {
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

    fileprivate var subtitle: String {
        switch self {
        case .passive:
            return LocalizationConstants.Earn.Compare.Passive.description
        case .staking:
            return LocalizationConstants.Earn.Compare.Staking.description
        case .active:
            return LocalizationConstants.Earn.Compare.Active.description
        }
    }

    fileprivate var items: [EarnProductCompareView.EarnProductItem] {
        [.userLevel, .assets, .rate, .periodicity, .payment, .withdrawal]
    }
}

extension EarnProductCompareView.EarnProductItem {

    @ViewBuilder func makeView(for step: EarnProductCompare.State.Step) -> some View {
        HStack {
            icon
                .renderingMode(.template)
                .foregroundColor(.semantic.primary)
            VStack(alignment: .leading) {
                Text(title(for: step))
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

    var icon: Image {
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

    func title(for step: EarnProductCompare.State.Step) -> String {
        typealias L10n = LocalizationConstants.Earn.Compare

        switch (self, step) {
        case (.userLevel, .staking):
            return L10n.Staking.Items.users
        case (.assets, .staking):
            return L10n.Staking.Items.assets
        case (.rate, .staking):
            return L10n.Staking.Items.rate
        case (.periodicity, .staking):
            return L10n.Staking.Items.periodicity
        case (.payment, .staking):
            return L10n.Staking.Items.payment
        case (.withdrawal, .staking):
            return L10n.Staking.Items.withdrawal
        case (.userLevel, .passive):
            return L10n.Passive.Items.users
        case (.assets, .passive):
            return L10n.Passive.Items.assets
        case (.rate, .passive):
            return L10n.Passive.Items.rate
        case (.periodicity, .passive):
            return L10n.Passive.Items.periodicity
        case (.payment, .passive):
            return L10n.Passive.Items.payment
        case (.withdrawal, .passive):
            return L10n.Passive.Items.withdrawal
        case (.userLevel, .active):
            return L10n.Active.Items.users
        case (.assets, .active):
            return L10n.Active.Items.assets
        case (.rate, .active):
            return L10n.Active.Items.rate
        case (.periodicity, .active):
            return L10n.Active.Items.periodicity
        case (.payment, .active):
            return L10n.Active.Items.payment
        case (.withdrawal, .active):
            return L10n.Active.Items.withdrawal
        }
    }

    func description(for step: EarnProductCompare.State.Step) -> String? {
        typealias L10n = LocalizationConstants.Earn.Compare

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

public struct EarnProductCompare: ReducerProtocol {

    var onDismiss: () -> Void

    public init (
        onDismiss: @escaping () -> Void
    ) {
        self.onDismiss = onDismiss
    }

    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case .didChangeStep(let step):
            state.currentStep = step
            return .none
        case .onDismiss:
            return .fireAndForget {
                onDismiss()
            }
        case .openUrl(let url):
            guard let url else {
                return .none
            }
            return .fireAndForget {
                #if canImport(UIKit)
                UIApplication.shared.open(url)
                #elseif canImport(AppKit)
                NSWorkspace.shared.open(url)
                #endif
            }
        }
    }

    public struct State: Equatable {
        public init(
            products: [EarnProduct]
        ) {
            self.steps = products.compactMap { product in
                switch product {
                case .active:
                    return .active
                case .staking:
                    return .staking
                case .savings:
                    return .passive
                default:
                    return nil
                }
            }
            self.currentStep = steps.first ?? .passive
        }

        public enum Step: Hashable, Identifiable {
            public var id: Self { self }

            case passive
            case staking
            case active
        }

        private let scrollEffectTransitionDistance: CGFloat = 300

        var scrollOffset: CGFloat = 0
        var currentStep: Step
        var steps: [Step]

        var gradientBackgroundOpacity: Double {
            switch scrollOffset {
            case _ where scrollOffset >= 0:
                return 1
            case _ where scrollOffset <= -scrollEffectTransitionDistance:
                return 0
            default:
                return 1 - Double(scrollOffset / -scrollEffectTransitionDistance)
            }
        }
    }

    public enum Action: Equatable {
        case didChangeStep(State.Step)
        case onDismiss
        case openUrl(URL?)
    }
}

struct EarnProductCompare_Previews: PreviewProvider {
    static var previews: some View {
        EarnProductCompareView(
            store: .init(
                initialState: .init(
                    products: [.savings, .staking, .active]
                ),
                reducer: EarnProductCompare(
                    onDismiss: {}
                )
            )
        )
        .app(App.preview)
    }
}
