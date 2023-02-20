// Copyright © Blockchain Luxembourg S.A. All rights reserved.
import SwiftUI

extension LargeSegmentedControl {

    struct Button: View {
        private let title: String
        private let icon: Icon?
        @Binding private var isOn: Bool

        init(
            title: String,
            icon: Icon? = nil,
            isOn: Binding<Bool>
        ) {
            self.title = title
            self.icon = icon
            _isOn = isOn
        }

        var body: some View {
            HStack(spacing: Spacing.padding1) {
                if let icon = icon {
                    if isOn {
                        icon.micro().color(.semantic.primary)
                    } else {
                        icon.micro()
                            .color(
                                Color(
                                    light: .semantic.body,
                                    dark: .palette.grey400
                                )
                            )
                    }
                }

                Text(title)
                    .typography(.paragraph2)
                    .foregroundColor(
                        isOn ? .semantic.primary : Color(
                            light: .semantic.body,
                            dark: .palette.grey400
                        )
                    )

            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .contentShape(RoundedRectangle(cornerRadius: 16))
            .onTapGesture {
                isOn.toggle()
            }
        }
            
    }
}

struct LargeSegmentedControlButton_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            PreviewController(title: "Item", isOn: true)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Selected")

            PreviewController(title: "Item", isOn: false)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Selected")
        }
        .padding()
    }

    struct PreviewController: View {
        let title: String
        @State var isOn: Bool

        var body: some View {
            LargeSegmentedControl<AnyHashable>.Button(
                title: title,
                isOn: $isOn
            )
        }
    }
}
