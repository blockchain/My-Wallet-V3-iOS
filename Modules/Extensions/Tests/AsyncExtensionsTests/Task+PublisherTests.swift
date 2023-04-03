import AsyncExtensions
import Combine
import CombineSchedulers
import Foundation
import SwiftExtensions
import XCTest

final class TaskPublisherTests: XCTestCase {

    func test_task_publisher_emits_value() async throws {

        let publisher = Task<String, Never>.Publisher {
            await hello()
        }

        let string = try await publisher.await()

        XCTAssertEqual(string, "Hello")
    }

    func test_task_throwing_publisher_emits_value() async throws {

        let publisher = Task<String, Swift.Error>.Publisher {
            try await maybe_hello()
        }

        let string = try await publisher.await()

        XCTAssertEqual(string, "Hello?")
    }

    func test_task_throwing_publisher_emits_error() async {

        let publisher = Task<String, Swift.Error>.Publisher {
            try await error()
        }

        do {
            _ = try await publisher.await()
            XCTFail("Expected failure, got success")
        } catch Error.test {
        } catch {
            XCTFail("Expected \(Error.test) but got \(error)")
        }
    }

    func test_publisher_to_task() async throws {

        let greeting = try await Just("Dorothy")
            .task { name in
                await hello() + " " + name + "!"
            }
            .await()

        XCTAssertEqual(greeting, "Hello Dorothy!")
    }

    func test_values_first() async throws {
        let value = try await Just(1).values.next()
        XCTAssertEqual(value, 1)
    }

    func test_ordering() async throws {

        @Sendable
        func double(_ n: Int) async -> Int {
            n * 2
        }

        let sequence = (1...10)
            .publisher
            .task(maxPublishers: .max(1)) { number in
                await double(number)
            }
            .values

        let result = await sequence.reduce(into: []) { s, n in
            s.append(n)
        }

        XCTAssertEqual(result, Array(1...10).map { $0 * 2 })
    }

    func test_performance_and_reliability() {

        typealias Route = [Either<Int, String>]

        let routes = Set(
            Either.randomRoutes(
                count: 1000,
                in: Array(0...9),
                and: "abcdef".map(String.init),
                bias: 0.1,
                length: 5...8
            )
        )

        let subject = PassthroughSubject<Route, Never>()
        var result: Set<Route> = []

        func reversed(_ route: Route) async -> Route { route.reversed() }

        let finished = expectation(description: #function)

        let s = subject
            .task(maxPublishers: .unlimited) {
                await reversed($0)
            }
            .sink(
                receiveCompletion: { _ in
                    finished.fulfill()
                },
                receiveValue: { either in
                    result.insert(either)
                }
            )
        addTeardownBlock { s.cancel() }

        for route in routes {
            subject.send(route)
        }

        subject.send(completion: .finished)

        wait(for: [finished], timeout: 0.1)

        XCTAssertEqual(Set(routes.map { $0.reversed() }), result)
    }

    enum Error: Swift.Error { case test }
}

private func hello() async -> String {
    "Hello"
}

private func maybe_hello() async throws -> String {
    "Hello?"
}

private func error() async throws -> String {
    throw TaskPublisherTests.Error.test
}
