// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@inlinable public func extract<T>(_: T.Type = T.self, from any: Any?, maxDepth: Int = 20, depth: Int = 0) -> T? {
    guard depth < maxDepth else { return nil }
    guard let any else { return nil }
    if let it = any as? T { return it }
    let mirror = Mirror(reflecting: any)
    for (_, child) in mirror.children {
        if let value = child as? T {
            return value
        } else if let next = extract(T.self, from: child, maxDepth: maxDepth, depth: depth + 1) {
            return next
        }
    }
    return nil
}
