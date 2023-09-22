// Copyright © Blockchain Luxembourg S.A. All rights reserved.
//: https://gist.github.com/ollieatkinson/13056d365d845831c58044182babbd2c

import Foundation

extension URLRequest {

    /// The cURL representation of the URLRequest, useful for debugging and executing requests outside of the app.
    var cURLCommand: String {

        var command = "curl"

        if let httpMethod {
            command.append(commandLineArgument: "-X \(httpMethod)")
        }

        if let httpBody, !httpBody.isEmpty {

            let bodyString = [
                ("\\", "\\\\"),
                ("`", "\\`"),
                ("\"", "\\\""),
                ("$", "\\$")
            ].reduce(String(data: httpBody, encoding: .utf8)) {
                $0?.replacingOccurrences(of: $1.0, with: $1.1)
            }!

            command.append(commandLineArgument: "-d \"\(bodyString)\"")
        }

        if let acceptEncoderHeader = allHTTPHeaderFields?["Accept-Encoding"], acceptEncoderHeader.contains("gzip") {
            command.append(commandLineArgument: "--compressed")
        }

        if let url, let cookies = HTTPCookieStorage.shared.cookies(for: url), !cookies.isEmpty {

            let cookieCommand = cookies.map { "\($0.name)=\($0.value);" }.joined()

            command.append(commandLineArgument: "--cookie \"\(cookieCommand)\"")
        }

        if let allHTTPHeaderFields {
            for (header, value) in allHTTPHeaderFields {
                command.append(
                    commandLineArgument: "-H '\(header): \(value.replacingOccurrences(of: "\'", with: "\\\'"))'"
                )
            }
        }

        if let url {
            command.append(commandLineArgument: "\"\(url.absoluteString)\"")
        }

        return command
    }
}

extension String {

    fileprivate mutating func append(commandLineArgument: String) {
        append(" \(commandLineArgument.trimmingCharacters(in: CharacterSet.whitespaces))")
    }
}
