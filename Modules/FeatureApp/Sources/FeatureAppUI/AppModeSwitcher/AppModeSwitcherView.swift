import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import DIKit
import Localization
import SwiftUI

public struct AppModeSwitcherView: View {
    let store: Store<AppModeSwitcherState, AppModeSwitcherAction>

    public init(
        store: Store<AppModeSwitcherState, AppModeSwitcherAction>
    ) {
        self.store = store
        ViewStore(store).send(.onInit)
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }, content: { viewStore in
            VStack {
                headerView
                selectionView
            }
            .sheet(
                isPresented: viewStore.binding(\.$isDefiIntroPresented),
                content: {
                    let store = store.scope(
                        state: \.defiWalletState,
                        action: AppModeSwitcherAction.defiWalletIntro
                    )
                    PrimaryNavigationView {
                        DefiWalletIntroView(store: store)
                    }
                }
            )
            .background(Color.clear)
        })
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.padding1, content: {
                Text(LocalizationConstants.AppModeSwitcher.totalBalanceLabel)
                    .typography(.caption2)
                    .foregroundColor(.semantic.title)

                Text(ViewStore(store)
                    .totalAccountBalance?
                    .toDisplayString(includeSymbol: true) ?? "")
                .typography(.title2)
                .foregroundColor(.semantic.title)
            })
            .padding(.top, Spacing.padding2)
            .padding(.leading, Spacing.padding3)
            Spacer()
        }
    }

    private var selectionView: some View {
        VStack {
            PrimaryRow(
                title: AppMode.trading.displayName,
                caption: nil,
                subtitle: ViewStore(store)
                    .brokerageAccountBalance?
                    .toDisplayString(includeSymbol: true) ?? ""
            ) {
                Icon
                    .portfolio
                    .color(.semantic.primary)
                    .frame(width: 24, height: 24)
            } trailing: {
                if ViewStore(store).currentAppMode == .trading {
                    checkMarkIcon
                } else {
                    chevronIcon
                }
            } action: {
                ViewStore(store).send(.onTradingTapped)
            }

            PrimaryRow(
                title: AppMode.pkw.displayName,
                caption: nil,
                subtitle: defiSubtitleString,
                description: defiDescriptionString,
                leading: {
                    Icon
                        .wallet
                        .color(.semantic.defi)
                        .frame(width: 24, height: 24)
                },
                trailing: {
                    if ViewStore(store).currentAppMode == .pkw {
                        checkMarkIcon
                    } else {
                        chevronIcon
                    }
                },
                action: {
                    ViewStore(store).send(.onDefiTapped)
                }
            )
        }
        .padding(.bottom, Spacing.padding6)
    }

    private var defiSubtitleString: String {
        guard ViewStore(store).shouldShowDefiModeIntro else {
            return ViewStore(store)
                .defiAccountBalance?
                .toDisplayString(includeSymbol: true) ?? ""
        }
        return LocalizationConstants.AppModeSwitcher.defiSubtitle
    }

    private var defiDescriptionString: String? {
        guard ViewStore(store).shouldShowDefiModeIntro else {
            return nil
        }
        return LocalizationConstants.AppModeSwitcher.defiDescription
    }

    private var chevronIcon: some View {
        Icon
            .chevronRight
            .color(.semantic.muted)
            .frame(width: 24, height: 24)
    }

    private var checkMarkIcon: some View {
        Icon
            .checkCircle
            .renderingMode(.template)
            .color(.semantic.primary)
            .frame(width: 24, height: 24)
    }
}
