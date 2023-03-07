// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum ToolKitError: Error {
    case timedOut
    case nullReference(AnyObject.Type, file: String = #file, line: Int = #line)
}
