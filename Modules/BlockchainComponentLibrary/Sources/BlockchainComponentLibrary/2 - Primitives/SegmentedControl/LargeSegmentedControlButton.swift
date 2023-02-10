// Copyright © Blockchain Luxembourg S.A. All rights reserved.
import SwiftUI

extension LargeSegmentedControl {

    struct Button: View {

        private let title: String

        @Binding private var isOn: Bool

        init(
            title: String,
            isOn: Binding<Bool>
        ) {
            self.title = title
            _isOn = isOn
        }

        var body: some View {
            Text(title)
                .typography(.paragraph2)
                .foregroundColor(
                    isOn ? .semantic.primary : Color(
                        light: .semantic.body,
                        dark: .palette.grey400
                    )
                )
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
