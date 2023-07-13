import JavaScriptCore

extension Compute {

    struct Eval: ComputeKeyword {

        let expression: String
        let context: [String: AnyJSON]?

        func compute() throws -> Any? {
            let js = try JSContext().or(throw: "Could not create JSContext")
            if let variables = context {
                for (key, value) in variables {
                    js.setObject(value.any, forKeyedSubscript: key as NSString)
                }
            }
            let result = js.evaluateScript(expression)
            if let exception = js.exception {
                throw AnyJSON.Error(exception.toString() ?? "Unknown Exception")
            }
            return result?.toObject()
        }
    }
}

extension Compute.Eval: CustomStringConvertible {

    public var description: String {
        "Eval(expression: \(expression), context: \(context ?? [:]))"
    }
}
