// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Extensions
import SwiftUI

// MARK: - Spacing Constants & Calculations

/// Constants for layout and grids.
///
/// To create a grid, please use `GridReader`
///
/// # Figma
/// [Spacing Rules](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=403%3A7380)
public enum Spacing {

    // MARK: Baseline

    /// Baseline dimension, all dimensions should be a multiple of this
    public static let baseline: CGFloat = 8

    // MARK: Grids

    /// Grid gutter width
    /// - Parameter columns: number of columns in your grid
    /// - Returns: An appropriate multiple of `baseline` given the current device and number of columns.
    public static func gutter(forColumns columns: Int) -> CGFloat {
        if columns >= 6 {
            return baseline
        } else {
            return baseline * 2
        }
    }

    // MARK: Padding

    /// Standard padding based on the container width.
    /// - Parameter width: With of the containing view. Defaults to the screen width.
    /// - Returns: Value to apply to `.padding()` modifier.
    public static func padding(forContainerWidth width: CGFloat = CGRect.screen.size.width) -> CGFloat {
        switch Breakpoint(containerWidth: width) {
        case .smallPhone:
            return padding2
        case .largePhone:
            return padding3
        }
    }

    /// spacing between vertically stacked text
    public static let textSpacing: CGFloat = 4

    /// 8pt
    public static let padding1: CGFloat = 8

    /// 16pt, default for small phones
    public static let padding2: CGFloat = 16

    /// 24pt, default for large phones (iPhone X and up)
    public static let padding3: CGFloat = 24

    /// 32pt
    public static let padding4: CGFloat = 32

    /// 40pt
    public static let padding5: CGFloat = 40

    /// 48pt
    public static let padding6: CGFloat = 48

    // MARK: Corner Radii

    /// Border radius to be used for standard buttons
    public static let buttonBorderRadius: CGFloat = 16

    /// Border radius for containers like cards
    public static let containerBorderRadius: CGFloat = 16

    /// Border radius for toast alerts and alert buttons. Pill-like style.
    /// - Parameter height: The height of the button
    /// - Returns: Corner radius to apply to the button.
    public static func roundedBorderRadius(for height: CGFloat) -> CGFloat {
        height / 2.0
    }
}

extension Spacing {
    /// A small helper for determining which default value to use for a given constant
    /// Currently design only differs between small and large iPhones.
    private enum Breakpoint {
        case smallPhone
        case largePhone

        init(containerWidth: CGFloat) {
            if containerWidth >= 375 { // iPhone X width
                self = .largePhone
            } else {
                self = .smallPhone
            }
        }
    }
}

// MARK: - Grid & GridReader

/// A set of measurement values for a given grid layout.
///
/// Use via `GridReader`
public struct Grid {

    /// The width of the view containing this grid
    public let containerWidth: CGFloat

    /// Number of columns
    public let columns: Int

    /// The spacing between each grid item
    public var gutter: CGFloat {
        Spacing.gutter(forColumns: columns)
    }

    /// The padding on the leading and trailing edges
    public var padding: CGFloat {
        Spacing.padding(forContainerWidth: containerWidth)
    }

    /// Width of each column
    public var columnWidth: CGFloat {
        (usableWidth - gutterTotalWidth) / CGFloat(columns)
    }

    /// Container width minus padding
    public var usableWidth: CGFloat {
        containerWidth - (padding * 2)
    }

    /// Sum of gutter widths
    private var gutterTotalWidth: CGFloat {
        gutter * CGFloat(columns - 1)
    }

    /// Helper for configuring a `LazyVGrid`'s `items`
    public var items: [GridItem] {
        Array(repeating: GridItem(.fixed(columnWidth), spacing: gutter), count: columns)
    }
}

extension Grid {

    /// Type for defining the variants of Grid Layouts available from design
    public struct Layout {
        var columns: Int
    }
}

extension Grid.Layout {

    /// A two column grid
    public static let two: Self = .init(columns: 2)

    /// A four column grid
    public static let four: Self = .init(columns: 4)

    /// A six column grid
    public static let six: Self = .init(columns: 6)
}

/// A container view for configuring a grid from the component library.
///
/// For example, this can be used to configure an `HStack`, or a `LazyVGrid`
///
/// ```
/// GridReader(layout: .two, width: 200) { grid in
///     HStack(spacing: grid.gutter) {
///         Text("Column 1")
///             .frame(width: grid.columnWidth)
///
///         Text("Column 2")
///             .frame(Width: grid.columnWidth)
///     }
///     .padding(.horizontal, grid.padding)
/// }
/// ```
///
/// See `Grid` for available variables.
///
/// > Note: If a `width` is not provided, `GeometryReader` is used to calculate the containing width.
/// This can cause issues with auto-sizing based on internal content.
public struct GridReader<Content: View>: View {

    let layout: Grid.Layout
    let width: CGFloat?
    let content: (Grid) -> Content

    /// Create a grid layout with the given content.
    ///
    /// > Note: If a `width` is not provided, `GeometryReader` is used to calculate the containing width.
    /// This can cause issues with auto-sizing based on internal content.
    ///
    /// - Parameters:
    ///   - layout: The layout (number of columns) preferred.
    ///   - width: Optional constant width for the grid. If unspecified, `GeometryReader` is used to fill the available width.
    ///   - content: A ViewBuilder with the grid passed in for use.
    public init(layout: Grid.Layout = .four, width: CGFloat? = nil, @ViewBuilder content: @escaping (Grid) -> Content) {
        self.layout = layout
        self.width = width
        self.content = content
    }

    public var body: some View {
        if let width {
            contentView(width: width)
        } else {
            GeometryReader { proxy in
                contentView(width: proxy.size.width)
            }
        }
    }

    @ViewBuilder private func contentView(width: CGFloat) -> some View {
        content(
            Grid(
                containerWidth: width,
                columns: layout.columns
            )
        )
    }
}

// MARK: - Previews

struct Spacing_Previews: PreviewProvider {
    static let fixedGridItem = GridItem(.fixed(460), spacing: 48)

    static var previews: some View {
        gridPreviews

        paddingPreviews

        borderRadiiPreviews
    }

    @ViewBuilder static var gridPreviews: some View {
        VStack(alignment: .leading) {
            Text("6 Column").typography(.title3)
            gridView(layout: .six, width: 375)
            gridView(layout: .six, width: 320)

            Text("4 Column").typography(.title3)
            gridView(layout: .four, width: 375)
            gridView(layout: .four, width: 320)

            Text("2 Column").typography(.title3)
            gridView(layout: .two, width: 375)
            gridView(layout: .two, width: 320)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Grids")
    }

    @ViewBuilder static var paddingPreviews: some View {
        LazyVGrid(columns: [fixedGridItem, fixedGridItem], spacing: 48) {
            paddingView(for: Spacing.padding1)
            paddingView(for: Spacing.padding2)
            paddingView(for: Spacing.padding3)
            paddingView(for: Spacing.padding4)
            paddingView(for: Spacing.padding5)
            paddingView(for: Spacing.padding6)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Padding")
    }

    @ViewBuilder static var borderRadiiPreviews: some View {
        LazyVGrid(columns: [fixedGridItem, fixedGridItem], spacing: 48) {
            radiusView(for: Spacing.buttonBorderRadius, title: "8pt (Buttons)")
            radiusView(for: Spacing.containerBorderRadius, title: "16pt (Containers)")
            radiusView(for: Spacing.roundedBorderRadius(for: 188), title: "100% (Alerts)")
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName("Border Radii")
    }

    @ViewBuilder static func gridView(layout: Grid.Layout, width: CGFloat) -> some View {
        GridReader(layout: layout, width: width) { grid in
            LazyVGrid(
                columns: grid.items,
                alignment: .leading
            ) {
                let column = 0..<grid.columns
                ForEach(column, id: \.self) { _ in
                    Rectangle()
                        .foregroundColor(.red.opacity(0.5))
                        .frame(height: Spacing.baseline * 5)
                }
            }
            .padding(.horizontal, grid.padding)
            .frame(width: grid.containerWidth)
        }
        .background(Color.white)
        .frame(height: Spacing.baseline * 5)
    }

    @ViewBuilder static func paddingView(for padding: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .border(Color.red, width: 0.5)
                .padding(padding)

            Text("\(padding)")
        }
        .frame(height: 188)
        .background(Color.gray.opacity(0.1))
    }

    @ViewBuilder static func radiusView(for radius: CGFloat, title: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius)
                .fill(Color.white)

            RoundedRectangle(cornerRadius: radius)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                .foregroundColor(.red)

            Text(title)
        }
        .frame(height: 188)
    }
}
