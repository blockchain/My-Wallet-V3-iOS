// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Algorithms
import SwiftUI

/// A vertical list of buttons used for displaying pickers.
///
/// Examples include date or country pickers contained in a grouped form.
///
/// Optionally contains trailing view, and can display inline pickers.
///
/// # Figma
///
/// [Picker](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=721%3A7394)
public struct PrimaryPicker<Selection: Hashable>: View {
    @Binding private var selection: Selection?
    private let rows: [Row]

    /// Create a set of picker buttons.
    ///
    /// - Parameters:
    ///   - selection: Binding for `selection` from `rows` for the currently selected row.
    ///   - rows: Items representing the rows within the picker. see `PrimaryPicker.Row`
    public init(selection: Binding<Selection?>, rows: [Row]) {
        _selection = selection
        self.rows = rows
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(rows.indexed(), id: \.element.id) { index, row in
                row.builder($selection)
                    .frame(minHeight: 48)
                    .background(
                        RowBackground(
                            position: position(for: index),
                            inputState: row.inputState
                        )
                    )
                    // if the state should be highlighted, ensure the row doesn't get obstructed by others in the list
                    .zIndex(row.inputState != .default ? 1 : 0)
            }
        }
    }

    private func position(for index: Int) -> Row.Position {
        guard rows.count > 1 else {
            return .single
        }

        switch index {
        case 0:
            return .top
        case rows.count - 1:
            return .bottom
        default:
            return .middle
        }
    }
}

extension PrimaryPicker {

    /// A row item within a `PrimaryPicker`
    public struct Row {

        fileprivate let id: UUID = UUID()

        fileprivate let inputState: InputState
        fileprivate let builder: (Binding<Selection?>) -> AnyView

        /// Create a row with trailing view & picker.
        ///
        /// - Parameters:
        ///   - title: Leading title displayed in the row
        ///   - identifier: ID for determining `selection`
        ///   - trailing: Trailing view displayed in the row. Commonly contains `Tag`.
        ///   - picker: Picker displayed below the row when selected. eg `DatePicker`
        /// - Returns: A row for use in `PrimaryPicker`
        public static func row(
            title: String?,
            identifier: Selection,
            placeholder: String? = nil,
            inputState: InputState = .default,
            @ViewBuilder trailing: @escaping () -> some View,
            @ViewBuilder picker: @escaping () -> some View
        ) -> Row {
            Row(inputState) { selection in
                PickerRow(
                    title: title,
                    placeholder: placeholder,
                    isActive: Binding(
                        get: {
                            selection.wrappedValue == identifier
                        },
                        set: { newValue in
                            if newValue {
                                selection.wrappedValue = identifier
                            } else {
                                selection.wrappedValue = nil
                            }
                        }
                    ),
                    picker: picker(),
                    trailing: trailing
                )
            }
        }

        /// Create a row with picker.
        ///
        /// - Parameters:
        ///   - title: Leading title displayed in the row
        ///   - identifier: ID for determining `selection`
        ///   - picker: Picker displayed below the row when selected. eg `DatePicker`
        /// - Returns: A row for use in `PrimaryPicker`
        public static func row(
            title: String?,
            identifier: Selection,
            placeholder: String? = nil,
            inputState: InputState = .default,
            @ViewBuilder picker: @escaping () -> some View
        ) -> Row {
            row(
                title: title,
                identifier: identifier,
                placeholder: placeholder,
                inputState: inputState,
                trailing: EmptyView.init,
                picker: picker
            )
        }

        /// Create a tappable row with trailing view.
        ///
        /// Used for displaying non-inline picker such as an alert or bottom sheet.
        ///
        /// - Parameters:
        ///   - title: Leading title displayed in the row
        ///   - identifier: ID for determining `selection`
        ///   - trailing: Trailing view displayed in the row. Commonly contains `Tag`.
        /// - Returns: A row for use in `PrimaryPicker`
        public static func row(
            title: String?,
            identifier: Selection,
            placeholder: String? = nil,
            inputState: InputState = .default,
            @ViewBuilder trailing: @escaping () -> some View
        ) -> Row {
            row(
                title: title,
                identifier: identifier,
                placeholder: placeholder,
                inputState: inputState,
                trailing: trailing,
                picker: EmptyView.init
            )
        }

        /// Create a tappable row with only a title.
        ///
        /// Used for displaying non-inline picker such as an alert or bottom sheet.
        ///
        /// - Parameters:
        ///   - title: Leading title displayed in the row
        ///   - identifier: ID for determining `selection`
        /// - Returns: A row for use in `PrimaryPicker`
        public static func row(
            title: String?,
            identifier: Selection,
            placeholder: String? = nil,
            inputState: InputState = .default
        ) -> Row {
            row(
                title: title,
                identifier: identifier,
                placeholder: placeholder,
                inputState: inputState,
                trailing: EmptyView.init,
                picker: EmptyView.init
            )
        }

        private init(
            _ inputState: InputState,
            @ViewBuilder _ view: @escaping (Binding<Selection?>) -> some View
        ) {
            self.inputState = inputState
            self.builder = { AnyView(view($0)) }
        }
    }
}

// MARK: - Private

#if canImport(UIKit)
extension PrimaryPicker {

    /// Shaped background with optional rounded corners.
    private struct RowBackground: View {

        let position: Row.Position
        let inputState: InputState

        private var corners: UIRectCorner {
            switch position {
            case .single:
                return .allCorners
            case .top:
                return [.topLeft, .topRight]
            case .bottom:
                return [.bottomLeft, .bottomRight]
            case .middle:
                return []
            }
        }

        var body: some View {
            ZStack {
                let borderColor: Color = inputState.borderColor ?? .semantic.medium
                if corners.isEmpty {
                    Rectangle()
                        .fill(Color.semantic.background)

                    Rectangle()
                        .stroke(borderColor, lineWidth: 1)
                } else {
                    RowShape(corners: corners)
                        .fill(Color.semantic.background)

                    RowShape(corners: corners)
                        .stroke(borderColor, lineWidth: 1)
                }
            }
        }
    }
}

/// Shape object for `PrimaryPicker.RowBackground`
///
/// Nesting this type causes previews to fail, so it is left at top level.
private struct RowShape: Shape {
    let corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(
                width: 15.6, // If you put 16 here too, it becomes fully rounded 🤷
                height: Spacing.buttonBorderRadius
            )
        )
        return Path(path.cgPath)
    }
}

#else

extension PrimaryPicker {

    /// Shaped background with optional rounded corners.
    private struct RowBackground: View {
        let position: Row.Position
        let inputState: InputState
        var body: some View {
            ZStack {
                Rectangle()
                    .fill(Color.semantic.background)
                Rectangle()
                    .stroke(Color.semantic.medium, lineWidth: 1)
            }
        }
    }
}
#endif

extension PrimaryPicker.Row {

    /// Position of row amoung others for determining shaped background
    fileprivate enum Position {
        case single
        case top
        case middle
        case bottom
    }

    /// Generic view used to display an individual picker row
    private struct PickerRow<Trailing: View, Picker: View>: View {
        let title: String?
        let placeholder: String?
        @Binding var isActive: Bool
        let picker: Picker
        @ViewBuilder let trailing: () -> Trailing

        var body: some View {
            VStack(spacing: 0) {
                Button(
                    action: {
                        withAnimation(.easeInOut) {
                            isActive.toggle()
                        }
                    },
                    label: {
                        HStack(spacing: 0) {
                            if let title {
                                Text(title)
                                    .typography(.body1)
                                    .foregroundColor(.semantic.title)
                                    .padding(.vertical, 12)
                            } else {
                                Text(placeholder ?? "")
                                    .typography(.body1)
                                    .foregroundColor(.semantic.muted)
                                    .padding(.vertical, 12)
                            }

                            Spacer()

                            trailing()
                        }
                    }
                )
                .padding(.horizontal, 16)

                if isActive, !(picker is EmptyView) {
                    Rectangle()
                        .fill(Color.semantic.medium)
                        .frame(height: 1)

                    picker
                        .padding(.horizontal, 16)
                }
            }
            .clipShape(Rectangle())
        }
    }
}

// MARK: - Previews

struct PrimaryPicker_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryPicker(
            selection: .constant(nil),
            rows: [
                .row(
                    title: nil,
                    identifier: "nil",
                    placeholder: "Remove me",
                    trailing: { TagView(text: "Trailing") }
                ),
                .row(
                    title: "One",
                    identifier: "one",
                    inputState: .error,
                    trailing: { TagView(text: "Trailing") }
                ),
                .row(title: "Two", identifier: "two"),
                .row(title: "Three", identifier: "three")
            ]
        )
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Multi")

        PrimaryPicker(
            selection: .constant(nil),
            rows: [
                .row(title: "One", identifier: "one"),
                .row(title: "Two", identifier: "two")
            ]
        )
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Two")

        PrimaryPicker(
            selection: .constant(nil),
            rows: [
                .row(title: "One", identifier: "one")
            ]
        )
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Single")

        PrimaryPicker(
            selection: .constant("one"),
            rows: [
                .row(title: "One", identifier: "one", picker: { Text("Picker") })
            ]
        )
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Single, selected with picker")
    }
}
