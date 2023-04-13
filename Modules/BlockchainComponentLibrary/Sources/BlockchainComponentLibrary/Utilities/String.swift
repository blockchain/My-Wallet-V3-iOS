extension String {

    public func data(in bundle: Bundle = .componentLibrary) -> Data? {
        guard let path = bundle.path(forResource: description, ofType: "json") else { return nil }
        let url = URL(fileURLWithPath: path)
        return try? Data(contentsOf: url)
    }

    public func json(in bundle: Bundle = .componentLibrary) -> Any? {
        guard let data = data(in: bundle) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
    }
}
