// https://github.com/ollieatkinson/Eumorphic/blob/anything/Sources/Anything/HeterogeneousContainerProtocol.swift

public enum SubscriptError: Error {
    case pathDoesNotExist([CodingKey], description: String)
    case message(String)
    case other(Error)
}

extension Any? {

    public subscript(first: AnyCodingKey, rest: AnyCodingKey...) -> Any? {
        get { self[[first] + rest] }
        set { self[[first] + rest] = newValue }
    }

    public subscript(path: some Collection<CodingKey>) -> Any? {
        get { try? get(path, from: self) }
        set { set(newValue, at: path, on: &self) }
    }
}

extension [String: Any] {

    public subscript(first: AnyCodingKey, rest: AnyCodingKey...) -> Any? {
        get { self[[first] + rest] }
        set { self[[first] + rest] = newValue }
    }

    public subscript(path: some Collection<CodingKey>) -> Value? {
        get { try? get(path) }
        set { set(newValue, at: path) }
    }

    public func get(_ path: some Collection<CodingKey>) throws -> Value {
        guard let (head, remaining) = path.headAndTail else { return self }
        guard let value = self[head.stringValue] else {
            throw SubscriptError.pathDoesNotExist(
                Array(path),
                description: "\(path) → Key \(head.stringValue) does not exist at \(self)"
            )
        }
        return try _get(remaining, from: value)
    }

    public mutating func set(_ value: Value?, at path: some Collection<CodingKey>) {
        guard let (head, remaining) = path.headAndTail else { return }
        let key = head.stringValue
        self[key] = _set(value, at: remaining, on: self[key] as Any)
    }
}

extension [Any] {

    public subscript(first: AnyCodingKey, rest: AnyCodingKey...) -> Any? {
        get { self[[first] + rest] }
        set { self[[first] + rest] = newValue }
    }

    public subscript(path: some Collection<CodingKey>) -> Element? {
        get { try? get(path) }
        set { set(newValue, at: path) }
    }

    public func get(_ path: some Collection<CodingKey>) throws -> Element {
        guard let (head, remaining) = path.headAndTail else { return self }
        guard let idx = head.intValue.map(bidirectionalIndex) else {
            throw SubscriptError.pathDoesNotExist(
                .init(path),
                description: "\(path) → Path indexing into array \(self) must be an Int - got: \(head.stringValue)"
            )
        }
        guard indices.contains(idx) else {
            throw SubscriptError.message("\(path) → Array index '\(idx)' out of bounds")
        }
        return try _get(remaining, from: self[idx])
    }

    public mutating func set(_ value: Element?, at path: some Collection<CodingKey>) {
        guard let (head, remaining) = path.headAndTail else { return }
        guard let idx = head.intValue.map(bidirectionalIndex) else { return }
        padded(to: idx, with: Any?.none as Any)
        self[idx] = _set(value, at: remaining, on: self[idx])
    }

    public func bidirectionalIndex(_ idx: Int) -> Int {
        guard idx < 0 else { return idx }
        guard !isEmpty else { return 0 }
        return (count + idx) % count
    }
}

extension RangeReplaceableCollection where Self: BidirectionalCollection {

    fileprivate mutating func padded(to size: Int, with value: @autoclosure () -> Element) {
        guard !indices.contains(index(startIndex, offsetBy: size)) else { return }
        append(contentsOf: (0..<(1 + size - count)).map { _ in value() })
    }
}

private func get<T>(
    _ path: some Collection<CodingKey>,
    from any: Any?,
    as _: T.Type = T.self
) throws -> T? {
    let any: Any = try _get(path, from: any)
    return try (any as? T).or(throw: SubscriptError.message("\(type(of: any)) is not \(T.self)"))
}

private func _get(_ path: some Collection<CodingKey>, from any: Any?) throws -> Any {
    switch any {
    case let array as [Any]:
        return try array.get(path)
    case let dictionary as [String: Any]:
        return try dictionary.get(path)
    case let fragment where path.isEmpty:
        return fragment as Any
    case let fragment:
        let description = String(describing: fragment)
        let type = type(of: fragment)
        throw SubscriptError.pathDoesNotExist(
            Array(path),
            description: "\(path) → Path indexing into \(description) of \(type) not allowed"
        )
    }
}

private func set(_ value: some Any, at path: some Collection<CodingKey>, on any: inout Any?) {
    any = _set(value, at: path, on: any)
}

private func _set(_ value: Any?, at path: some Collection<CodingKey>, on any: Any?) -> Any {
    guard let (crumb, _) = path.headAndTail else { return recursiveFlatMapOptional(value) as Any }
    switch crumb {
    case _ where crumb.intValue != nil:
        var array = (any as? [Any]) ?? []
        array.set(value, at: path)
        return array
    case _:
        var dictionary = (any as? [String: Any]) ?? [:]
        dictionary.set(value, at: path)
        return dictionary
    }
}

extension Collection {

    fileprivate var headAndTail: (head: Element, tail: SubSequence)? {
        guard let head = first else { return nil }
        return (head, dropFirst())
    }
}

extension String {

    fileprivate func splitDotPath() -> [String] {
        isEmpty
            ? []
            : split(separator: ".", omittingEmptySubsequences: true).map(String.init)
    }
}

extension Collection<String> {
    fileprivate var codingPath: [CodingKey] { map { AnyCodingKey($0) } }
}

extension Any? {

    public subscript(first: CodingKey, rest: CodingKey...) -> Any? {
        get { self[[first] + rest] }
        set { self[[first] + rest] = newValue }
    }

    public subscript(first: String, rest: String...) -> Any? {
        get { self[[first] + rest] }
        set { self[[first] + rest] = newValue }
    }

    public subscript(dotPath string: String) -> Any? {
        get { self[string.splitDotPath()] }
        set { self[string.splitDotPath()] = newValue }
    }

    public subscript(_ collection: some Collection<String>) -> Any? {
        get { self[collection.codingPath] }
        set { self[collection.codingPath] = newValue }
    }
}

extension [String: Any] {

    public subscript(first: CodingKey, rest: CodingKey...) -> Any? {
        get { self[[first] + rest] }
        set { self[[first] + rest] = newValue }
    }

    public subscript(first: String, rest: String...) -> Any? {
        get { self[[first] + rest] }
        set { self[[first] + rest] = newValue }
    }

    public subscript(dotPath string: String) -> Any? {
        get { self[string.splitDotPath()] }
        set { self[string.splitDotPath()] = newValue }
    }

    public subscript(_ collection: some Collection<String>) -> Value? {
        get { self[collection.codingPath] }
        set { self[collection.codingPath] = newValue }
    }
}

extension [Any] {

    public subscript(first: CodingKey, rest: CodingKey...) -> Any? {
        get { self[[first] + rest] }
        set { self[[first] + rest] = newValue }
    }

    public subscript(first: String, rest: String...) -> Any? {
        get { self[[first] + rest] }
        set { self[[first] + rest] = newValue }
    }

    public subscript(dotPath string: String) -> Any? {
        get { self[string.splitDotPath()] }
        set { self[string.splitDotPath()] = newValue }
    }

    public subscript(_ collection: some Collection<String>) -> Element? {
        get { self[collection.codingPath] }
        set { self[collection.codingPath] = newValue }
    }
}
