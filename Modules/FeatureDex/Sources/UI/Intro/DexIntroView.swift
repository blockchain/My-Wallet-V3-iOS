import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import Foundation
import Localization
import SwiftUI

public struct DexIntroView: View {
    let store: StoreOf<DexIntro>

    public init(store: StoreOf<DexIntro>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            PrimaryNavigationView {
                contentView
                    .primaryNavigation(trailing: {
                        Button {
                            viewStore.send(.onDismiss)
                        } label: {
                            Icon.close
                        }
                    })
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }

    private var contentView: some View {
        VStack {
            ZStack {
                carouselContentSection()
                buttonsSection()
                    .padding(.bottom, Spacing.padding6)
            }
            .background(
                ZStack {
                    Color.white.ignoresSafeArea()
                }
            )
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
                    step.makeView()
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
                PrimaryButton(
                    title: LocalizationConstants.Dex.Onboarding.button,
                    action: {
                        viewStore.send(.onDismiss)
                    }
                )
                .cornerRadius(Spacing.padding4)
                .shadow(
                    color: Color.black.opacity(0.15),
                    radius: 8,
                    y: 3
                )
            }
            .padding(.horizontal, Spacing.padding3)
        }
    }
}

extension DexIntro.State.Step {
    @ViewBuilder func makeView() -> some View {
        carouselView(
            image: {
                image
            },
            title: title,
            text: text
        )
        .tag(self)
    }

    @ViewBuilder private func carouselView(
        @ViewBuilder image: () -> Image,
        title: String,
        text: String,
        description: String? = nil,
        badge: String? = nil,
        badgeTint: Color? = nil
    ) -> some View {
        VStack {
            image()
            VStack(
                alignment: .center,
                spacing: Spacing.padding3
            ) {
                Text(title)
                    .lineLimit(2)
                    .typography(.title3)
                    .multilineTextAlignment(.center)
                Text(text)
                    .multilineTextAlignment(.center)
                    .frame(width: 80.vw)
                    .typography(.paragraph1)

                if let description {
                    ZStack {
                        VStack(alignment: .leading) {
                            if let badge {
                                TagView(
                                    text: badge,
                                    variant: .default,
                                    size: .small,
                                    foregroundColor: badgeTint
                                )
                            }
                            Text(description)
                                .typography(.caption1)
                                .foregroundColor(.semantic.body)
                        }
                    }
                    .padding(Spacing.padding2)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white.opacity(0.25))
                    )
                    .shadow(
                        color: Color.black.opacity(0.12),
                        radius: 8,
                        y: 3
                    )
                }
                Spacer()
            }
            .frame(height: 300)
        }
        .padding([.leading, .bottom, .trailing], Spacing.padding3)
    }
}

struct DexIntroView_Previews: PreviewProvider {
    static var previews: some View {
        DexIntroView(
            store: Store(
                initialState: DexIntro.State(),
                reducer: DexIntro(
                    app: App.preview,
                    onDismiss: {
                        print("onDismiss")
                    }
                )
            )
        )
    }
}
