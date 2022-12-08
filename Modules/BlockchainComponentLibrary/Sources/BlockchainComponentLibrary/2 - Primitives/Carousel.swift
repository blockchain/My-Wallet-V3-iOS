#if canImport(UIKit)
import SwiftUI
import UIKit

public struct Carousel<Data, ID, Content>: View where Data: RandomAccessCollection, ID: Hashable, Content: View {

    public let data: Data
    public let id: KeyPath<Data.Element, ID>
    public let content: (Data.Element) -> Content

    public let isLazy: Bool
    public let maxVisible: CGFloat
    public let spacing: CGFloat

    @State var height: CGFloat = 1
    @StateObject var observer = CarouselDelegate()

    public var body: some View {
        if data.isNotEmpty {
            cells
        }
    }

    var cell: CellSize {
        CellSize(
            maxVisible: maxVisible,
            outOf: data.count,
            axis: .horizontal,
            spacing: spacing
        )
    }

    @ViewBuilder var cells: some View {
        GeometryReader { proxy in
            let width = cell.length(toFit: proxy.size)
            let padding = max(.zero, proxy.frame(in: .global).minX - spacing)
            ScrollView(.horizontal, showsIndicators: false) {
                Group {
                    if isLazy {
                        LazyHStack(alignment: .top, spacing: spacing) {
                            cellView(width: width, padding: padding)
                        }
                    } else {
                        HStack(alignment: .top, spacing: spacing) {
                            cellView(width: width, padding: padding)
                        }
                    }
                }
                .findScrollView { scrollView in
                    scrollView.delegate = observer
                    scrollView.alwaysBounceHorizontal = data.count > ceil(maxVisible).i
                }
            }
            .frame(width: 100.vw)
            .offset(x: -proxy.frame(in: .global).minX)
        }
        .onPreferenceChange(CarouselHeightKey.self) { height in
            self.height = height
        }
        .frame(height: height)
    }

    @ViewBuilder func cellView(width: CGFloat, padding: CGFloat) -> some View {
        Spacer()
            .frame(width: padding)
        ForEach(data, id: id) { element in
            content(element)
                .frame(width: width)
                .frame(maxHeight: .infinity)
                .fixedSize()
                .background(
                    GeometryReader { cell in
                        if isLazy || cell.isInBoundsHorizontally {
                            ZStack {}.preference(key: CarouselHeightKey.self, value: cell.size.height)
                        }
                    }
                )
        }
        Spacer()
            .frame(width: padding)
    }

    public init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        lazy: Bool = false,
        maxVisible: CGFloat = 1.7,
        spacing: CGFloat = 16,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.isLazy = lazy
        self.maxVisible = maxVisible
        self.spacing = spacing
        self.data = data
        self.id = id
        self.content = content
    }
}

struct CarouselHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

class CarouselDelegate: NSObject, UIScrollViewDelegate, ObservableObject {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0
    }
}

extension GeometryProxy {

    fileprivate var isInBoundsHorizontally: Bool {
        var global = frame(in: .global)
        global.origin.y = CGRect.screen.minY
        return CGRect.screen.intersects(global)
    }
}

extension Carousel {

    struct CellSize: Equatable {

        var count: Int
        var maxVisible: CGFloat
        var axis: Axis
        var spacing: CGFloat
        var padding: EdgeInsets

        init(
            maxVisible: CGFloat,
            outOf cellCount: Int,
            axis: Axis,
            spacing: CGFloat = .zero,
            padding: EdgeInsets = .zero
        ) {
            self.count = cellCount
            self.maxVisible = maxVisible
            self.axis = axis
            self.spacing = spacing
            self.padding = padding
        }

        func toFit(_ size: CGSize) -> CGSize {
            let length = length(toFit: size)
            let size = (CGRect(origin: .zero, size: size) - padding).size
            return axis == .horizontal
                ? .init(width: length, height: size.height)
                : .init(width: size.width, height: length)
        }

        func length(toFit size: CGSize) -> CGFloat {
            let n = maxVisible
            let c = count.cg
            let w = size.along(axis)
            let pBoth = padding.along(axis)
            let pLeading = axis == .vertical ? padding.top : padding.leading
            guard n > 0, c > 0 else { return 0 }
            let x: CGFloat
            if c > n {
                x = (w - pLeading - spacing * (ceil(n) - 1)) / n
            } else {
                x = (w - pBoth - spacing * (c - 1)) / c
            }
            return max(0, x)
        }
    }
}

extension CGSize {

    func along(_ axis: Axis) -> CGFloat {
        switch axis {
        case .vertical: return height
        case .horizontal: return width
        }
    }
}

extension EdgeInsets {

    func along(_ axis: Axis) -> CGFloat {
        switch axis {
        case .vertical: return vertical
        case .horizontal: return horizontal
        }
    }
}

struct Carousel_Previews: PreviewProvider {

    struct Card: Hashable {
        let icon: Icon
        let title: String
        let message: String
    }

    static var previews: some View {
        let data = [
            Card(icon: .interestCircle, title: "One", message: "1"),
            Card(icon: .lockClosed, title: "Two", message: "2"),
            Card(icon: .link, title: "Three", message: "3"),
            Card(icon: .laptop, title: "Four", message: "4")
        ]
        Carousel(data, id: \.self, maxVisible: 2, spacing: 10) { card in
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.semantic.light)
                VStack(alignment: .leading, spacing: 8.pt) {
                    HStack {
                        card.icon.frame(width: 20.pt, height: 20.pt)
                        Text(card.title)
                            .foregroundColor(.semantic.body)
                    }
                    Text(card.message)
                        .foregroundColor(.semantic.title)
                    Spacer()
                    SmallMinimalButton(title: "Learn More") { }
                }
                .padding()
            }
            .typography(.paragraph1)
            .aspectRatio(5 / 3, contentMode: .fit)
        }
    }
}
#endif
