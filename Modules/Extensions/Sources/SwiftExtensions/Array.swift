@resultBuilder
public enum ArrayBuilder<Element> {
    public static func buildBlock<C: Collection>(_ components: C...) -> [Element] where C.Element == Element { components.flatMap { $0 }.array }
    public static func buildExpression(_ expression: Element) -> [Element] { [expression] }
    public static func buildExpression(_ expression: [Element]) -> [Element] { expression }
    public static func buildArray(_ components: [[Element]]) -> [Element] { components.flatMap { $0 } }
    public static func buildPartialBlock(first: Element) -> [Element] { [first] }
    public static func buildPartialBlock(first: [Element]) -> [Element] { first }
    public static func buildPartialBlock(accumulated: [Element], next: Element) -> [Element] { accumulated + [next] }
    public static func buildPartialBlock(accumulated: [Element], next: [Element]) -> [Element] { accumulated + next }
    public static func buildBlock() -> [Element] { [] }
    public static func buildEither(first: [Element]) -> [Element] { first }
    public static func buildEither(second: [Element]) -> [Element] { second }
    public static func buildIf(_ element: [Element]?) -> [Element] { element ?? [] }
    public static func buildPartialBlock(first: Never) -> [Element] {}
    public static func buildPartialBlock(first: Void) -> [Element] { [] }
}

@resultBuilder
public struct SetBuilder<Element: Hashable> {
    public static func buildBlock<C: Collection>(_ components: C...) -> Set<Element> where C.Element == Element { components.flatMap { $0 }.set }
    public static func buildExpression(_ expression: Element) -> Set<Element> { [expression] }
    public static func buildExpression(_ expression: some Collection<Element>) -> Set<Element> { expression.set }
    public static func buildArray(_ components: Set<[Element]>) -> Set<Element> { components.reduce(into: Set()) { s, n in s.formUnion(n.set) } }
    public static func buildArray(_ components: [Set<Element>]) -> Set<Element> { components.reduce(into: Set()) { s, n in s.formUnion(n) } }
    public static func buildPartialBlock(first: Element) -> Set<Element> { [first] }
    public static func buildPartialBlock(first: some Collection<Element>) -> Set<Element> { first.set }
    public static func buildPartialBlock(accumulated: some Collection<Element>, next: Element) -> Set<Element> { accumulated.set.union([next]) }
    public static func buildPartialBlock(accumulated: some Collection<Element>, next: some Collection<Element>) -> Set<Element> { accumulated.set.union(next.set) }
    public static func buildBlock() -> Set<Element> { [] }
    public static func buildEither(first: some Collection<Element>) -> Set<Element> { first.set }
    public static func buildEither(second: some Collection<Element>) -> Set<Element> { second.set }
    public static func buildIf(_ element: Set<Element>?) -> Set<Element> { element ?? [] }
    @_disfavoredOverload
    public static func buildIf(_ element: [Element]?) -> Set<Element> { element?.set ?? [] }
    public static func buildPartialBlock(first: Never) -> Set<Element> {}
    public static func buildPartialBlock(first: Void) -> Set<Element> { [] }
}
