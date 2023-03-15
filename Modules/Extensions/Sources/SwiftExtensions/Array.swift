@resultBuilder
public enum ArrayBuilder<Element> {
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
    public static func buildPartialBlock(first: Element) -> Set<Element> { [first] }
    public static func buildPartialBlock(first: Set<Element>) -> Set<Element> { first }
    public static func buildPartialBlock(accumulated: Set<Element>, next: Element) -> Set<Element> { accumulated.union([next]) }
    public static func buildPartialBlock(accumulated: Set<Element>, next: Set<Element>) -> Set<Element> { accumulated.union(next) }
    public static func buildBlock() -> Set<Element> { [] }
    public static func buildEither(first: Set<Element>) -> Set<Element> { first }
    public static func buildEither(second: Set<Element>) ->Set<Element> { second }
    public static func buildIf(_ element: Set<Element>?) -> Set<Element> { element ?? [] }
    public static func buildPartialBlock(first: Never) -> Set<Element> {}
    public static func buildPartialBlock(first: Void) -> Set<Element> { [] }
}
