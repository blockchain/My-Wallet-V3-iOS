// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import SwiftUI

public struct RootView: View {

    @State var colorScheme: ColorScheme
    @State var layoutDirection: LayoutDirection

    private static let data: NavigationLinkProviderList = [
        "1 - Base": [
            NavigationLinkProvider(view: ColorsExamplesView(), title: "🌈 Colors"),
            NavigationLinkProvider(view: TypographyExamplesView(), title: "🔠 Typography"),
            NavigationLinkProvider(view: SpacingExamplesView(), title: "🔳 Spacing Rules"),
            NavigationLinkProvider(view: IconsExamplesView(), title: "🖼 Icons")
        ],
        "2 - Primitives": [
            NavigationLinkProvider(view: TabBarExamplesView(), title: "🎼 TabBar"),
            NavigationLinkProvider(view: ButtonExamplesView(), title: "🕹 Buttons"),
            NavigationLinkProvider(view: PrimaryDividerExamples(), title: "🗂 Dividers"),
            NavigationLinkProvider(view: PrimarySwitchExamples(), title: "🔌 PrimarySwitch"),
            NavigationLinkProvider(view: TagViewExamples(), title: "🏷 Tag"),
            NavigationLinkProvider(view: CheckboxExamples(), title: "✅ Checkbox"),
            NavigationLinkProvider(view: RichTextExamples(), title: "🤑 Rich Text"),
            NavigationLinkProvider(view: SegmentedControlExamples(), title: "🚥 SegmentedControl"),
            NavigationLinkProvider(view: InputExamples(), title: "⌨️ Input"),
            NavigationLinkProvider(view: PrimaryPickerExamples(), title: "⛏ Picker"),
            NavigationLinkProvider(view: AlertExamples(), title: "⚠️ Alert"),
            NavigationLinkProvider(view: AlertToastExamples(), title: "🚨 AlertToast"),
            NavigationLinkProvider(view: PageControlExamples(), title: "📑 PageControl"),
            NavigationLinkProvider(view: PrimarySliderExamples(), title: "🎚 Slider"),
            NavigationLinkProvider(view: RadioExamples(), title: "🔘 Radio"),
            NavigationLinkProvider(view: ChartBalanceExamples(), title: "⚖️ Chart Balance"),
            NavigationLinkProvider(view: LineGraphExamples(), title: "📈 Line Graph"),
            NavigationLinkProvider(view: FilterExamples(), title: "🗳 Filter")
        ],
        "3 - Compositions": [
            NavigationLinkProvider(view: PrimaryNavigationExamples(), title: "✈️ Navigation"),
            NavigationLinkProvider(view: CalloutCardExamples(), title: "💬 CalloutCard"),
            NavigationLinkProvider(view: SectionHeadersExamples(), title: "🪖 SectionHeaders"),
            NavigationLinkProvider(view: RowExamplesView(), title: "🚣‍♀️ Rows"),
            NavigationLinkProvider(view: BottomSheetExamples(), title: "📄 BottomSheet"),
            NavigationLinkProvider(view: SearchBarExamples(), title: "🔎 SearchBar"),
            NavigationLinkProvider(view: AlertCardExamples(), title: "🌋 AlertCard"),
            NavigationLinkProvider(view: PromoCardExamples(), title: "🛎 PromoCard"),
            NavigationLinkProvider(view: AnnouncementCardExamples(), title: "🎙 AnnouncementCard"),
            NavigationLinkProvider(view: LargeAnnouncementCardExamples(), title: "📡 LargeAnnouncementCard")
        ]
    ]

    public init(colorScheme: ColorScheme = .light, layoutDirection: LayoutDirection = .leftToRight) {
        _colorScheme = State(initialValue: colorScheme)
        _layoutDirection = State(initialValue: layoutDirection)
    }

    public static var content: some View {
        NavigationLinkProviderView(data: data)
    }

    public var body: some View {
        PrimaryNavigationView {
            NavigationLinkProviderView(data: RootView.data)
                .primaryNavigation(title: "📚 Component Library") {
                    Button(colorScheme == .light ? "🌗" : "🌓") {
                        colorScheme = colorScheme == .light ? .dark : .light
                    }

                    Button(layoutDirection == .leftToRight ? "➡️" : "⬅️") {
                        layoutDirection = layoutDirection == .leftToRight ? .rightToLeft : .leftToRight
                    }
                }
        }
        .colorScheme(colorScheme)
        .environment(\.layoutDirection, layoutDirection)
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(
            ColorScheme.allCases,
            id: \.self
        ) { colorScheme in
            RootView(colorScheme: colorScheme)
        }
    }
}
