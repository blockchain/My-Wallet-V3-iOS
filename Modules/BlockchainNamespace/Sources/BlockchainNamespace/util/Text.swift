import Combine
import SwiftUI

public struct InterpolatedText<Placeholder: View, Success: View, Failure: View>: View {

    @BlockchainApp var app
    @Environment(\.context) var context

    var tokens: [Token] = []
    var placeholder: () -> Placeholder
    var success: (String) -> Success
    var failure: (Error) -> Failure

    @StateObject var object = Object()

    public init(
        _ string: DefaultString,
        placeholder: @escaping () -> Placeholder = ProgressView.init,
        success: @escaping (String) -> Success = Text.init,
        failure: @escaping (Error) -> Failure = { _ in EmptyView() }
    ) {
        self.tokens = string.tokens
        self.placeholder = placeholder
        self.success = success
        self.failure = failure
    }

    public var body: some View {
        Group {
            switch object.string {
            case .none:
                placeholder()
            case .success(let string)?:
                success(string)
            case .failure(let error)?:
                failure(error)
            }
        }
        .onAppear {
            object.query(tokens, on: app, in: context)
        }
    }
}

extension InterpolatedText {

    @_disfavoredOverload
    public init(
        _ tokens: [Token],
        placeholder: @escaping () -> Placeholder = ProgressView.init,
        success: @escaping (String) -> Success = Text.init,
        failure: @escaping (Error) -> Failure = { _ in EmptyView() }
    ) {
        self.tokens = tokens
        self.placeholder = placeholder
        self.success = success
        self.failure = failure
    }
}

extension InterpolatedText {

    public enum Token {
        case literal(String)
        case reference(Tag.Event)
    }

    public struct DefaultString: ExpressibleByStringInterpolation, ExpressibleByStringLiteral {

        var tokens: [Token] = []

        public init(stringLiteral value: String) {
            self.tokens = [.literal(value)]
        }

        public init(stringInterpolation: Self) {
            self.tokens = stringInterpolation.tokens
        }
    }

    public struct Interpolation: StringInterpolationProtocol {

        var tokens: [Token] = []

        public init(literalCapacity: Int, interpolationCount: Int) {
            self.tokens = []
            tokens.reserveCapacity(literalCapacity + interpolationCount)
        }

        public mutating func appendLiteral(_ literal: String) {
            tokens.append(.literal(literal))
        }

        public mutating func appendInterpolation(_ value: Tag.Event) {
            tokens.append(.reference(value))
        }
    }

    class Object: ObservableObject {

        @Published var string: Result<String, Error>?

        init() {}

        func query(_ tokens: [Token], on app: AppProtocol, in context: Tag.Context) {

            tokens.map { token -> AnyPublisher<Result<String, Swift.Error>, Never> in
                switch token {
                case .literal(let string):
                    return .just(.success(string))
                case .reference(let reference):
                    return app.publisher(for: reference.key(to: context).in(app), as: String.self)
                        .map(\.result)
                        .eraseToAnyPublisher()
                }
            }
            .combineLatest()
            .map { values -> Result<String, Error> in
                do {
                    return try .success(values.reduce(into: "") { $0 += try $1.get() })
                } catch {
                    return .failure(error)
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$string)
        }
    }
}
