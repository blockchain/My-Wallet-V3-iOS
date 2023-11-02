// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

extension RandomAccessCollection where Element: Publisher, Element.Output == Bool {

    /// `FlatMap` all `Publisher`, creating a concatenated stream that returns `true` at first chance.
    public func flatMapConcatFirst() -> AnyPublisher<Element.Output, Element.Failure> {
        reduce(AnyPublisher<Element.Output, Element.Failure>.just(false)) { stream, thisPublisher in
            stream
                .flatMap { result -> AnyPublisher<Element.Output, Element.Failure> in
                    switch result {
                    case true:
                        // If the stream result was true, return.
                        .just(true)
                    case false:
                        // Else, concatenate stream on the array.
                        thisPublisher
                            .eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
        }
    }
}
