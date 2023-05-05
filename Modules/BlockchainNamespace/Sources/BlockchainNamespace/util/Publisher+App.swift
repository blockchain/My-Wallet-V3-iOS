// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import SwiftExtensions

extension Publisher {
    public func ignoreFailure<NewFailure: Error>(
        setFailureType failureType: NewFailure.Type = NewFailure.self,
        redirectsErrorTo app: AppProtocol,
        file: String = #fileID,
        line: Int = #line
    ) -> AnyPublisher<Output, NewFailure> {
        `catch` { [app] error -> Combine.Empty<Output, NewFailure> in
            app.post(error: error, file: file, line: line)
            return Combine.Empty<Output, NewFailure>()
        }
        .eraseToAnyPublisher()
    }
}
