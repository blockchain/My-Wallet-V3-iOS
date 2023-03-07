import Accelerate
import CoreGraphics
import Extensions
import SwiftUI

/// A view displaying a line graph, with a vertical selection bar when touched.
///
///     LineGraph(
///         selection: $selectedIndex,
///         selectionTitle: { i, d in
///             Text("\(data[i])")
///         },
///         minimumTitle: { i, d in
///             Text("\(data[i])")
///         },
///         maximumTitle: { i, d in
///             Text("\(data[i])")
///         }
///         data: data,
///         tolerance: 3
///     )
///
/// # Figma
///
/// [Graph](https://www.figma.com/file/nlSbdUyIxB64qgypxJkm74/03---iOS-%7C-Shared?node-id=1125%3A7721)
public struct LineGraph<Title: View, Minimum: View, Maximum: View>: View {

    @Binding public var selection: Int?

    public let isLive: Bool
    public let selectionTitle: (_ index: Int, _ data: Double) -> Title

    public let minimumTitle: (_ index: Int, _ data: Double) -> Minimum
    public let maximumTitle: (_ index: Int, _ data: Double) -> Maximum

    public var isHighlighted: Bool {
        _highlight == nil
    }

    let padding = (
        highlight: 20.cg,
        trailing: 26.cg,
        text: 20.cg
    )

    private let memoized: LineShape.Memoized

    @Environment(\.lineGraphColor) var lineGraphColor

    @State private var _size: CGSize = .zero
    @State private var _highlight: CGFloat?
    @State private var _titleWidth: CGFloat = 0
    @State private var _minimumTitleSize: CGSize = .zero
    @State private var _maximumTitleSize: CGSize = .zero

    public init(
        selection: Binding<Int?> = .constant(nil),
        @ViewBuilder selectionTitle: @escaping (Int, Double) -> Title,
        @ViewBuilder minimumTitle: @escaping (Int, Double) -> Minimum,
        @ViewBuilder maximumTitle: @escaping (Int, Double) -> Maximum,
        data: [Double],
        tolerance: Int = 5,
        density: Int = 250,
        isLive: Bool = false
    ) {
        _selection = selection
        self.selectionTitle = selectionTitle
        self.minimumTitle = minimumTitle
        self.maximumTitle = maximumTitle
        self.isLive = isLive
        self.memoized = LineShape.Memoized[
            raw: data,
            tolerance: tolerance,
            density: density
        ]
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            GeometryReader { geometry in
                Group {
                    Group {
                        stroked()
                        faded()
                    }
                    .drawingGroup()
                    .contentShape(Rectangle())
                    .anchorPreference(key: GraphSizePreferenceKey.self, value: .bounds) { anchor in
                        geometry[anchor].size
                    }
                    dot(geometry)
                }
                .padding([.top, .bottom], padding.highlight)
                Group {
                    if let ((i, max), (j, min)) = memoized.minMax, min != max {
                        minimum(index: i, value: min)
                        maximum(index: j, value: max)
                    }
                }
                .padding(.bottom, padding.text + _minimumTitleSize.height)
            }
            .onPreferenceChange(GraphSizePreferenceKey.self) { size in
                _size = size
            }
            Group {
                highlight()
                    .animation(.none)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let percentage = (value.location.x / _size.width).clamped(to: 0...1)
                    _highlight = percentage
                    selection = index(from: percentage)
                }
                .onEnded { _ in
                    _highlight = nil
                    selection = nil
                }
        )
        .padding(.trailing, isLive ? padding.trailing : 0)
    }

    private func index(from percentage: CGFloat) -> Int {
        round((memoized.raw.count - 1).cg * percentage).i.clamped(to: 0...memoized.raw.count)
    }

    var line: (shape: LineShape, integral: LineShape) {
        _highlight == nil ? memoized.smooth : memoized.sharp
    }

    @ViewBuilder private func fill() -> some View {
        line.integral
            .fill(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            lineGraphColor.opacity(0.08),
                            lineGraphColor.opacity(0.00)
                        ]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }

    @ViewBuilder private func stroked() -> some View {
        line.shape.stroke(lineGraphColor, style: StrokeStyle(lineWidth: 4, lineJoin: .round))
            .clipShape(ClippedRectangle(x: _highlight ?? 1, y: 1))
    }

    @ViewBuilder private func faded() -> some View {
        line.shape.stroke(
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        lineGraphColor.opacity(0.3),
                        lineGraphColor.opacity(0.05)
                    ]
                ),
                startPoint: .leading,
                endPoint: .trailing
            ),
            style: StrokeStyle(lineWidth: 2, lineJoin: .round)
        )
    }

    @ViewBuilder private func dot(_ geometry: GeometryProxy) -> some View {
        if isLive {
            if let end = line.shape.vertices.last {
                let length: CGFloat = 8
                let offset = end * _size - (length / 2)
                Circle()
                    .fill(lineGraphColor)
                    .frame(width: length, height: length)
                    .pulse()
                    .transformEffect(
                        CGAffineTransform(translationX: offset.x, y: offset.y)
                    )
            }
        }
    }

    @ViewBuilder private func highlight() -> some View {
        if let percentage = _highlight ?? selection.map({ $0.cg / memoized.raw.count.cg }) {
            Rectangle()
                .fill(Color.semantic.title)
                .frame(width: 1)
                .padding(.top, Spacing.padding3)
                .offset(x: _size.width * percentage)
            GeometryReader { geometry in
                let index = index(from: percentage)
                let width = _size.width - _titleWidth
                selectionTitle(index, memoized.raw[index])
                    .padding(.horizontal, 1)
                    .offset(
                        x: (percentage * _size.width - _titleWidth / 2)
                            .clamped(to: Spacing.padding1...max(Spacing.padding1, width - Spacing.padding1))
                    )
                    .anchorPreference(key: TitleWidthPreferenceKey.self, value: .bounds) { anchor in
                        geometry[anchor].size.width
                    }
                    .onPreferenceChange(TitleWidthPreferenceKey.self) { value in
                        _titleWidth = value
                    }
            }
        }
    }

    @ViewBuilder private func minimum(index: Int, value: Double) -> some View {
        if selection == nil {
            GeometryReader { geometry in
                let offset = line.shape.min * geometry.size
                let width = _size.width - _minimumTitleSize.width
                minimumTitle(index, value)
                    .transformEffect(
                        CGAffineTransform(
                            translationX: (offset.x - _minimumTitleSize.width / 2)
                                .clamped(to: Spacing.padding1...max(Spacing.padding1, width - Spacing.padding1)),
                            y: _size.height + padding.text
                        )
                    )
                    .anchorPreference(key: MinTitleSizePreferenceKey.self, value: .bounds) { anchor in
                        geometry[anchor].size
                    }
                    .onPreferenceChange(MinTitleSizePreferenceKey.self) { value in
                        _minimumTitleSize = value
                    }
            }
        }
    }

    @ViewBuilder private func maximum(index: Int, value: Double) -> some View {
        if selection == nil {
            GeometryReader { geometry in
                let offset = line.shape.max * geometry.size
                let width = _size.width - _maximumTitleSize.width
                maximumTitle(index, value)
                    .transformEffect(
                        CGAffineTransform(
                            translationX: (offset.x - _maximumTitleSize.width / 2)
                                .clamped(to: Spacing.padding1...max(Spacing.padding1, width - Spacing.padding1)),
                            y: offset.y
                                .clamped(to: 0...) - _maximumTitleSize.height
                        )
                    )
                    .anchorPreference(key: MaxTitleSizePreferenceKey.self, value: .bounds) { anchor in
                        geometry[anchor].size
                    }
                    .onPreferenceChange(MaxTitleSizePreferenceKey.self) { value in
                        _maximumTitleSize = value
                    }
            }
        }
    }
}

/// Environment key set by `LineGraph`
private struct LineGraphColor: EnvironmentKey {
    static var defaultValue = Color.semantic.primary
}

extension EnvironmentValues {

    /// Accent color for line graph in `LineGraph`
    ///
    /// Defaults to `.semantic.primary`
    public var lineGraphColor: Color {
        get { self[LineGraphColor.self] }
        set { self[LineGraphColor.self] = newValue }
    }
}

extension View {

    @warn_unqualified_access
    public func lineGraphColor(_ color: Color) -> some View {
        environment(\.lineGraphColor, color)
    }
}

struct LineShape: Shape {

    static let empty: LineShape = .init(data: [], tolerance: 0, density: 1, vertices: [])

    var animatableData: AnimatablePoints {
        get { .init(points: vertices.map(\.animatableData)) }
        set { vertices = newValue.points.map(\.point) }
    }

    var data: [Double] {
        didSet { vertices = LineShape.vertices(of: data, tolerance: tolerance) }
    }

    var vertices: [CGPoint] {
        didSet { (min, max) = minMax() }
    }

    var min: CGPoint = .zero
    var max: CGPoint = .zero

    let tolerance: Int
    let density: Int
    let isClosed: Bool

    init(
        data: [Double],
        tolerance: Int,
        density: Int,
        closed isClosed: Bool = false,
        vertices: [CGPoint]
    ) {
        self.data = data
        self.tolerance = tolerance
        self.density = density
        self.isClosed = isClosed
        self.vertices = vertices
        (self.min, self.max) = minMax()
    }

    static func vertices(of y: [Double], tolerance: Int, density: Int = 300) -> [CGPoint] {
        let x = Array(stride(from: 0.d, through: 1, by: 1 / (y.count - 1).d))
        let scale = Scale<Double>(domain: x, range: y)
        let x2 = stride(from: 0.d, through: 1, by: 1 / (density - 1).d)
        let y2: [Double]
        if tolerance > 1 {
            y2 = x2.map(scale.linear).slidingAverages(radius: tolerance, prefixAndSuffix: .reverseToFit)
        } else {
            y2 = x2.map(scale.linear)
        }
        return zip(x2, y2).map { CGPoint(x: $0, y: $1) }
    }

    func minMax() -> (min: CGPoint, max: CGPoint) {
        guard !vertices.isEmpty, let ((min, _), (max, _)) = data.indexed().minAndMax(using: \.element, by: >) else {
            return (.zero, .zero)
        }

        func find(_ i: Int, using comparator: (CGFloat, CGFloat) -> Bool) -> CGPoint {

            var iterator = (
                left: vertices.reversed().makeIterator(),
                right: vertices.makeIterator()
            )

            let normalised = ((i.d / data.count.d) * density.d).i.clamped(to: 0..<vertices.count)
            var current = vertices[normalised]

            let left = iterator.left.next() ?? current
            let right = iterator.right.next() ?? current

            let itr = comparator(left.y, right.y) ? AnyIterator(iterator.left) : AnyIterator(iterator.right)

            while let next = itr.next(), comparator(next.y, current.y) {
                current = next
            }

            return current
        }

        return (
            find(min, using: >),
            find(max, using: <)
        )
    }

    func path(in rect: CGRect) -> Path {
        let vertices = vertices.map { $0 * rect.size }
        if let first = vertices.first {
            return Path { path in
                path.move(to: first)
                for point in vertices.dropFirst() {
                    path.addLine(to: point)
                }
                if isClosed {
                    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
                    path.closeSubpath()
                }
            }
        } else {
            return Path()
        }
    }
}

extension LineShape {

    public struct AnimatablePoints: VectorArithmetic {

        var points: [CGPoint.AnimatableData]

        public static func + (lhs: Self, rhs: Self) -> Self {
            data(lhs: lhs, rhs: rhs, applying: +)
        }

        public static func - (lhs: Self, rhs: Self) -> Self {
            data(lhs: lhs, rhs: rhs, applying: -)
        }

        public mutating func scale(by rhs: Double) {
            for index in points.indices {
                points[index].scale(by: rhs)
            }
        }

        public var magnitudeSquared: Double {
            points.reduce(0) { sum, point in
                sum + point.magnitudeSquared
            }
        }

        public static var zero: AnimatableData {
            .init(points: [])
        }

        static func data(
            lhs: Self,
            rhs: Self,
            applying function: (CGPoint.AnimatableData, CGPoint.AnimatableData) -> CGPoint.AnimatableData
        ) -> Self {
            var points: [CGPoint.AnimatableData] = []
            let (min, max) = [lhs.points.count, rhs.points.count].minAndMax()!
            for index in 0..<max {
                if index < min {
                    points.append(function(lhs.points[index], rhs.points[index]))
                } else if rhs.points.count > lhs.points.count, let lastLeftPoint = lhs.points.last {
                    points.append(function(lastLeftPoint, rhs.points[index]))
                } else if let lastPoint = points.last, index < lhs.points.count {
                    points.append(function(lastPoint, lhs.points[index]))
                }
            }
            return .init(points: points)
        }
    }
}

private var __memoized: [LineShape.MemoizedKey: LineShape.Memoized] = [:]

extension LineShape {

    fileprivate struct MemoizedKey: Hashable {
        let raw: [Double], tolerance: Int, density: Int
    }

    fileprivate struct Memoized {

        typealias Key = MemoizedKey

        static subscript(raw raw: [Double], tolerance tolerance: Int, density density: Int) -> Memoized {
            self[Key(raw: raw, tolerance: tolerance, density: density)]
        }

        static subscript(key: MemoizedKey) -> Memoized {
            guard let memoized = __memoized[key] else {
                __memoized[key] = LineShape.memoized(
                    raw: key.raw,
                    tolerance: key.tolerance,
                    density: key.density
                )
                return self[key]
            }
            return memoized
        }

        let raw: [Double]
        let tolerance: Int
        let density: Int

        let smooth: (
            shape: LineShape,
            integral: LineShape
        )

        let sharp: (
            shape: LineShape,
            integral: LineShape
        )

        let minMax: (
            min: (Int, Double),
            max: (Int, Double)
        )?
    }

    fileprivate static func memoized(raw: [Double], tolerance: Int, density: Int) -> LineShape.Memoized {

        let (min, max) = raw.minAndMax() ?? (0, .greatestFiniteMagnitude)
        let span = (max - min).d
        let normal = span > 0 ? raw.map { value in
            1.d - (value.d - min.d) / span
        } : Array(repeating: 1, count: raw.count)

        let smooth = LineShape.vertices(
            of: normal,
            tolerance: tolerance,
            density: density
        )
        let sharp = LineShape.vertices(
            of: normal,
            tolerance: 1,
            density: density
        )

        return .init(
            raw: raw,
            tolerance: tolerance,
            density: density,
            smooth: (
                shape: LineShape(
                    data: normal,
                    tolerance: tolerance,
                    density: density,
                    vertices: smooth
                ),
                integral: LineShape(
                    data: normal,
                    tolerance: tolerance,
                    density: density,
                    closed: true,
                    vertices: smooth
                )
            ),
            sharp: (
                shape: LineShape(
                    data: normal,
                    tolerance: 1,
                    density: density,
                    vertices: sharp
                ),
                integral: LineShape(
                    data: normal,
                    tolerance: 1,
                    density: density,
                    closed: true,
                    vertices: sharp
                )
            ),
            minMax: raw.indexed().minAndMax(using: \.element, by: >)
        )
    }
}

extension AnimatablePair where First: BinaryFloatingPoint, Second: BinaryFloatingPoint {
    var point: CGPoint { .init(x: first.cg, y: second.cg) }
}

private struct GraphSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

private struct TitleWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct MinTitleSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

private struct MaxTitleSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct LineGraph_Previews: PreviewProvider {
    static var previews: some View {
        PreviewContainer(isLive: false)
            .previewLayout(.sizeThatFits)
        PreviewContainer(isLive: true)
            .previewLayout(.sizeThatFits)
    }

    struct PreviewContainer: View {
        @State var selection: Int?
        let isLive: Bool
        let data = [19164.48, 19276.59, 19439.75, 21379.48, 22847.46, 23150.79, 23869.92, 23490.58, 22745.48, 23824.99, 23253.37, 23715.53, 24693.58, 26443.21, 26246.58, 27036.69, 27376.37, 28856.59, 28982.56, 29393.75, 32195.46, 33000.78, 32035.03, 34046.67, 36860.41, 39486.04, 40670.25, 40240.72, 38240.09, 35544.94, 34011.82, 37393.13, 39158.47, 36828.52, 36065.2, 35793.01, 36632.35, 36020.13, 35538.98, 30797.88, 33002.38, 32099.74, 32276.84, 32243.26, 32541.8, 30419.17, 33403.17, 34314.26, 34318.1, 33136.46, 33522.9, 35529.66, 37676.25, 37002.09, 38278.61, 39323.26, 38928.1, 46364.3, 46589.58, 44878.17, 48013.38, 47471.4, 47185.19, 48720.37, 47951.85, 49160.1, 52118.23, 51608.15, 55916.5, 56001.2, 57487.86, 54123.4, 48880.43, 50624.84, 46800.42, 46340.31, 46155.87, 45113.92, 49618.43, 48356.04, 50477.7, 48448.91, 48861.38, 48881.59, 51169.7, 52299.33, 54881.52, 55997.23, 57764.0, 57253.28, 61258.73, 59133.47, 55754.72, 56872.38, 58913.0, 57665.9, 58075.1, 58085.8, 57411.17, 54204.96, 54477.46, 52508.23, 51415.92, 55074.47, 55863.93, 55783.71, 57627.67, 58730.13, 58735.25, 58736.92, 59031.32, 57076.49, 58206.55, 59054.1, 58020.46, 55947.27, 58048.59, 58102.58, 59774.0, 59964.87, 59834.74, 63554.44, 62969.12, 63252.63, 61455.98, 60087.09, 56251.48, 55703.14, 56507.91, 53808.8, 51731.71, 51153.13, 50110.53, 49075.58, 54056.64, 55071.46, 54884.1, 53584.15, 57796.62, 57857.5, 56610.46, 57213.33, 53241.72, 57473.23, 56428.16, 57380.27, 58928.81, 58280.73, 55883.5, 56750.0, 49007.09, 49702.27, 49922.52, 46736.58, 46441.64, 43596.24, 42912.19, 36964.27, 40784.32, 37280.35, 37528.3, 34754.54, 38728.59, 38410.5, 39266.04, 38445.29, 35689.62, 34647.67, 35684.59, 37310.54, 36662.64, 37585.24, 39188.59, 36885.51, 35530.38, 35816.17, 33514.87, 33450.19, 37338.36, 36704.57, 37313.18, 35494.9, 39066.82, 40525.8, 40188.56, 38324.87, 38068.04, 35729.82, 35524.17, 35592.35, 31686.55, 32447.59, 33674.66, 34639.38, 31640.58, 32160.91, 34644.45, 34456.67, 35847.7, 35047.36, 33536.88, 33856.86, 34688.98, 35309.3, 33747.97, 34211.01, 33839.04, 32877.41, 33818.52, 33515.57, 34227.64, 33158.25, 32686.56, 32814.61, 31738.59, 31421.25, 31520.66, 31783.49, 30815.94, 29790.24, 32118.06, 32297.89, 33581.63, 34279.34, 35365.2, 37318.14, 39405.95, 40002.53, 40005.93, 42214.15, 41659.06, 40000.46, 39193.94, 38138.0, 39750.14, 40882.0, 42825.95, 44634.13, 43816.14, 46333.46, 45608.37, 45611.46, 44417.78, 47833.98, 47112.19, 47056.41, 45982.55, 44648.57, 44777.86, 46734.65, 49327.75, 48932.02, 49335.68, 49523.5, 47744.58, 48972.09, 46962.8, 49056.86, 48897.65, 48806.78, 47074.77, 47155.87, 48862.76, 49329.01, 50035.33, 49947.38, 51769.06, 52677.4, 46809.17, 46078.38, 46368.69, 44847.48, 45144.79, 46059.12, 44968.76, 47072.12, 48167.85, 47785.26, 47263.6, 48259.45, 47249.38, 42901.56, 40619.27, 43604.76, 44888.96, 42815.56, 42742.01, 43182.63, 42238.2, 41011.16, 41522.38, 43757.81, 48140.11, 47727.1, 48205.72, 49143.95, 51505.83, 55343.76, 53801.1, 53867.3, 55122.59, 54625.74, 57452.01, 56242.94, 57406.69, 57397.74, 61641.17, 60948.78, 61546.21, 61971.59, 64287.64, 66063.56, 62354.86, 60697.06, 61277.28, 60884.18, 63070.54, 60345.17, 58538.49, 60587.09, 62249.18, 61731.29, 61373.44, 61029.5, 63241.11, 62954.86, 61441.83, 61072.32, 61516.31, 63293.22, 67562.17, 66954.11, 64976.73, 64838.81, 64254.67, 64420.94, 65468.75, 63584.25, 60172.26, 60381.35, 56921.34, 58133.02, 59777.98, 58755.9, 56301.52, 57578.22, 57187.54, 58935.45, 53588.21, 54801.15, 57292.28, 57828.45, 57025.79, 57229.76, 56508.48, 53713.84, 49253.86, 49380.43, 50564.63, 50645.41, 50511.12, 47659.68, 47137.46]
        var body: some View {
            ZStack {
                LineGraph(
                    selection: $selection,
                    selectionTitle: { i, d in
                        Text("\(i) == \(d) -> \(data.count)")
                            .typography(.caption2)
                            .foregroundColor(.semantic.title)
                    },
                    minimumTitle: { _, _ in
                        Text("min")
                    },
                    maximumTitle: { _, _ in
                        Text("max")
                            .background(Color.semantic.light)
                    },
                    data: data,
                    isLive: isLive
                )
                .background(Color.semantic.light)
            }
        }
    }
}
