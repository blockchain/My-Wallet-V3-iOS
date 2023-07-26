// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BlockchainComponentLibrary
import BlockchainNamespace
import Localization
import SwiftUI

private typealias HomeLocalization = LocalizationConstants.Dashboard.Portfolio
private typealias TabsLocalization = LocalizationConstants.TabItems
private typealias UITourLocalization = LocalizationConstants.Onboarding.UITour

enum Tab: Hashable {
    case home
    case prices
    case fab
    case trade
    case activity
}

struct TourStep: Hashable {
    let tab: Tab
    let title: String
    let message: String
    let imageName: String
    let tipOffset: CGFloat
}

extension TourStep {

    static let home = TourStep(
        tab: .home,
        title: UITourLocalization.stepHomeTitle,
        message: UITourLocalization.stepHomeMessage,
        imageName: "ui_tour_home",
        tipOffset: (UIScreen.main.bounds.width / 5) * -2
    )

    static let prices = TourStep(
        tab: .prices,
        title: UITourLocalization.stepPricesTitle,
        message: UITourLocalization.stepPricesMessage,
        imageName: "ui_tour_prices",
        tipOffset: (UIScreen.main.bounds.width / 5) * -1
    )

    static let fab = TourStep(
        tab: .fab,
        title: UITourLocalization.stepFabTitle,
        message: UITourLocalization.stepFabMessage,
        imageName: "ui_tour_fab",
        tipOffset: .zero
    )

    static let trade = TourStep(
        tab: .trade,
        title: UITourLocalization.stepBuySellTitle,
        message: UITourLocalization.stepBuySellMessage,
        imageName: "ui_tour_trade",
        tipOffset: UIScreen.main.bounds.width / 5
    )

    static let activity = TourStep(
        tab: .activity,
        title: UITourLocalization.stepActivityTitle,
        message: UITourLocalization.stepActivityMessage,
        imageName: "ui_tour_activity",
        tipOffset: (UIScreen.main.bounds.width / 5) * 2
    )

    static let onboardingChecklist = TourStep(
        tab: .home,
        title: UITourLocalization.stepChecklistTitle,
        message: UITourLocalization.stepChecklistMessage,
        imageName: "ui_tour_checklist",
        tipOffset: .zero
    )

    static var allSteps: [TourStep] = [
        .trade,
        .prices,
        .fab,
        .activity,
        .onboardingChecklist
    ]

    var nextStep: TourStep? {
        let steps = TourStep.allSteps
        guard let i = steps.firstIndex(of: self), i < steps.endIndex - 1 else {
            return nil
        }
        return steps[i + 1]
    }

    var previousStep: TourStep? {
        let steps = TourStep.allSteps
        guard let i = steps.firstIndex(of: self), i > 0 else {
            return nil
        }
        return steps[i - 1]
    }

    var isLastStep: Bool {
        nextStep == nil
    }

    var actionTitle: String {
        guard isLastStep else {
            return UITourLocalization.tourNextStepCTA
        }
        return UITourLocalization.tourFinishTourCTA
    }
}

struct UITourView: View {

    let close: () -> Void
    let completion: () -> Void
    @State private var popupOpacity: CGFloat
    @State private var currentStep: TourStep
    @State private var selectedTab: AnyHashable

    init(
        initialStep: TourStep? = nil,
        close: @escaping () -> Void,
        completion: @escaping () -> Void
    ) {
        self.close = close
        self.completion = completion
        let initialStep = initialStep ?? TourStep.allSteps[0]
        _currentStep = State(initialValue: initialStep)
        _selectedTab = State(initialValue: initialStep.tab)
        _popupOpacity = State(initialValue: 0)
    }

    var body: some View {
        ZStack {
            mainContent

            // faded layer
            if currentStep == .onboardingChecklist {
                // hide tab bar behind layer
                Color.semantic.fadedBackground
                    .edgesIgnoringSafeArea(.all)
            } else {
                // hide all content but tab bar behind layer
                Color.semantic.fadedBackground
                    .edgesIgnoringSafeArea(.top)
                    // pad to make space for tab bar
                    .padding(.bottom, Spacing.padding6)
                    // add some extra room so the selection bar is visible
                    .padding(.bottom, Spacing.padding1)
            }

            // popup
            VStack {
                Spacer()

                UITourPopup(
                    currentStep: $currentStep,
                    close: close,
                    completion: completion
                )
                .opacity(popupOpacity)
                .animation(.easeIn, value: popupOpacity)

                // checklist overview, so it's visible above the faded background
                if currentStep == .onboardingChecklist {
                    onboardingChecklistOverview
                        .transition(.opacity)
                        .animation(.easeIn)
                }
            }
            // pad for tab bar content
            .padding(.bottom, Spacing.padding6)
            // pad to add spacing between view and tab bar
            .padding(.bottom, Spacing.padding2)
        }
        .onChange(of: selectedTab) { tab in
            let potentialStep = TourStep.allSteps.first(
                where: { AnyHashable($0.tab) == tab }
            )
            guard let step = potentialStep, currentStep != step else {
                // reset to currently selected step
                selectedTab = currentStep.tab
                return
            }
            currentStep = step
        }
        .gesture(
            DragGesture(minimumDistance: 50, coordinateSpace: .global)
                .onEnded { gesture in
                    // check if the user swiped horizontally by checking the delta of
                    // the drag direction on horizontal and vertical axis for the dominant value
                    let horizontalTranslation = abs(gesture.translation.width)
                    let verticalTranslation = abs(gesture.translation.height)
                    let didSwipeHorizontally = horizontalTranslation > verticalTranslation
                    guard didSwipeHorizontally else {
                        return
                    }
                    // if the dominant drag was on the horizontal axis
                    // move to the next or previous step based on the drag direction
                    let didSwipeLeft = gesture.translation.width < 0
                    if didSwipeLeft {
                        if let nextStep = currentStep.nextStep {
                            currentStep = nextStep
                        }
                    } else {
                        if let previewStep = currentStep.previousStep {
                            currentStep = previewStep
                        }
                    }
                }
        )
        .onChange(of: currentStep) { step in
            selectedTab = step.tab
        }
        .onAppear {
            popupOpacity = 1
        }
    }

    var stubHomeScreen: some View {
        PrimaryNavigationView {
            VStack {
                VStack(spacing: Spacing.padding3) {
                    VStack(spacing: Spacing.textSpacing) {
                        Text(HomeLocalization.EmptyState.title)
                            .typography(.title3)

                        Text(HomeLocalization.EmptyState.subtitle)
                            .typography(.paragraph1)
                    }
                    .multilineTextAlignment(.center)

                    PrimaryButton(title: HomeLocalization.EmptyState.cta) {
                        // no-op
                    }
                }
                .padding(Spacing.padding3)
                .padding(.top, Spacing.padding5)

                Spacer()
            }
            .primaryNavigation(
                leading: { Icon.user },
                title: TabsLocalization.home,
                trailing: { Icon.qrCode }
            )
        }
    }

    var onboardingChecklistOverview: some View {
        OnboardingChecklistOverview(
            store: .init(
                initialState: OnboardingChecklist.State(),
                reducer: OnboardingChecklist.reducer,
                environment: OnboardingChecklist.Environment(
                    app: App.preview,
                    userState: .empty(),
                    presentBuyFlow: { _ in },
                    presentKYCFlow: { _ in },
                    presentPaymentMethodLinkingFlow: { _ in },
                    analyticsRecorder: AnalyticsEventRecorder(
                        analyticsServiceProviders: []
                    )
                )
            )
        )
        .disabled(true) // avoid default behavior
        .onTapGesture(perform: completion) // complete the flow on tap
        // add a rounded box around the component to highlight it
        .padding(Spacing.padding1)
        .background(
            Color.semantic.background
                .clipShape(
                    RoundedRectangle(cornerRadius: Spacing.containerBorderRadius)
                )
        )
        .padding(.horizontal, Spacing.padding2)
        .padding(.bottom, Spacing.padding2)
    }

    var mainContent: some View {
        TabBar(activeTabIdentifier: $selectedTab, highlightBarVisible: true) {
            stubHomeScreen // background for checklist selection

            stubHomeScreen
                .tabBarItem(
                    .tab(
                        identifier: TourStep.home.tab,
                        icon: .home,
                        title: TabsLocalization.home
                    )
                )

            stubHomeScreen
                .tabBarItem(
                    .tab(
                        identifier: TourStep.prices.tab,
                        icon: .lineChartUp,
                        title: TabsLocalization.prices
                    )
                )

            stubHomeScreen
                .tabBarItem(
                    .fab(
                        identifier: TourStep.fab.tab,
                        isActive: .constant(false)
                            .didSet { _ in currentStep = .fab },
                        isPulsing: false
                    )
                )

            stubHomeScreen
                .tabBarItem(
                    .tab(
                        identifier: TourStep.trade.tab,
                        icon: .cart,
                        title: TabsLocalization.buyAndSell
                    )
                )

            stubHomeScreen
                .tabBarItem(
                    .tab(
                        identifier: TourStep.activity.tab,
                        icon: .pending,
                        title: TabsLocalization.activity
                    )
                )
        }
    }
}

private struct PopupTipTriangle: Shape {

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

private struct UITourPopup: View {

    @Binding var currentStep: TourStep
    let close: () -> Void
    let completion: () -> Void

    var body: some View {
        VStack(spacing: .zero) {
            popupBoxContent
                .zIndex(.infinity) // make this the top layer so the tip is behind it
            popupTip
                .offset(x: currentStep.tipOffset)
        }
        .clipped()
        .padding(.horizontal, Spacing.padding2)
        .padding(.bottom, Spacing.padding1)
        .animation(.easeInOut, value: currentStep.tipOffset)
    }

    private var popupTip: some View {
        ZStack {
            let tipSize = CGSize(width: 20, height: 10)
            // a "background" to avoid weird shape when the tip is at the edge
            Rectangle()
                .fill(Color.semantic.background)
                .frame(width: tipSize.width, height: tipSize.width)
                // remove height - height of triangle below
                .padding(.top, -(tipSize.width - tipSize.height))
                .offset(y: -tipSize.height) // offset by the remaining height

            // The actual tip
            PopupTipTriangle()
                .fill(Color.semantic.background)
                .frame(width: tipSize.width, height: 10)
        }
    }

    private var popupBoxContent: some View {
        ZStack(alignment: .top) {
            VStack(spacing: .zero) {
                popupImage

                VStack(alignment: .leading, spacing: Spacing.padding3) {
                    popupCopy
                    popupPageControls
                }
                .padding(Spacing.padding3)
            }

            popupCloseButtonBar
        }
        .background(Color.semantic.background)
        .clipShape(
            RoundedRectangle(cornerRadius: Spacing.containerBorderRadius)
        )
    }

    private var popupImage: some View {
        Image(currentStep.imageName, bundle: .onboarding)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: 164)
            .background(Color.semantic.muted)
    }

    private var popupCopy: some View {
        VStack(alignment: .leading, spacing: Spacing.textSpacing) {
            Text(currentStep.title)
                .typography(.title3)

            Text(currentStep.message)
                .typography(.paragraph1)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var popupPageControls: some View {
        HStack {
            PageControl(
                controls: TourStep.allSteps,
                selection: $currentStep
            )
            // undo internal padding of page control
            .padding(-Spacing.padding3)

            Spacer()

            // wrapping both buttons in a ZStack toggling the opacity of each
            // for a smoother animation when the popup moves
            ZStack {
                SmallPrimaryButton(title: currentStep.actionTitle) {
                    if let nextStep = currentStep.nextStep {
                        currentStep = nextStep
                    }
                }
                .opacity(currentStep.isLastStep ? 0 : 1)

                SmallBuyButton(title: currentStep.actionTitle) {
                    completion()
                }
                .opacity(currentStep.isLastStep ? 1 : 0)
            }
        }
    }

    private var popupCloseButtonBar: some View {
        HStack {
            Spacer()
            Icon.close
                .color(.semantic.background)
                .frame(width: 24, height: 24)
                .onTapGesture(perform: close)
        }
        .padding(Spacing.padding2)
    }
}

#if DEBUG

struct UITourView_Previews: PreviewProvider {

    struct TestView: View {

        struct AlertState: Hashable, Identifiable {
            let id: String
            let title: String
            let message: String
            let dismissButtonTitle: String

            static let closed = AlertState(
                id: "alert_closed",
                title: "Closed!",
                message: "Go explore the app!",
                dismissButtonTitle: "OK"
            )

            static let completed = AlertState(
                id: "alert_completed",
                title: "Completed!",
                message: "Go buy some crypto!",
                dismissButtonTitle: "OK"
            )
        }

        let initialStep: TourStep?
        @State var alertState: AlertState?

        init(initialStep: TourStep? = nil) {
            self.initialStep = initialStep
        }

        var body: some View {
            UITourView(
                initialStep: initialStep,
                close: {
                    alertState = .closed
                },
                completion: {
                    alertState = .completed
                }
            )
            .alert(item: $alertState) { item in
                Alert(
                    title: Text(item.title),
                    message: Text(item.message),
                    dismissButton: .default(Text(item.dismissButtonTitle))
                )
            }
        }
    }

    static var previews: some View {
        // preview actual flow

        TestView()

        // preview single steps

        TestView(initialStep: .home)

        TestView(initialStep: .prices)

        TestView(initialStep: .fab)

        TestView(initialStep: .trade)

        TestView(initialStep: .activity)

        TestView(initialStep: .onboardingChecklist)
    }
}

#endif
