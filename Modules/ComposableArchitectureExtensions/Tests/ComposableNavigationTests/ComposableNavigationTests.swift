import ComposableArchitecture
@testable import ComposableNavigation
import SwiftUI
import XCTest

final class ComposableNavigationTests: XCTestCase {

    func test_route() throws {

        var state = TestState()
        let testReducer = TestReducer()

        _ = testReducer.reduce(into: &state, action: .navigate(to: .test))
        XCTAssertEqual(state.route?.action, .navigateTo)
        XCTAssertEqual(state.route?.route, .test)

        _ = testReducer.reduce(into: &state, action: .enter(into: .story))
        XCTAssertEqual(state.route?.action, .enterInto(.default))
        XCTAssertEqual(state.route?.route, .story)

        _ = testReducer.reduce(into: &state, action: .dismiss())
        XCTAssertNil(state.route)

        _ = testReducer.reduce(into: &state, action: .enter(into: .story, context: .fullScreen))
        XCTAssertEqual(state.route?.action, .enterInto(.fullScreen))
        XCTAssertEqual(state.route?.route, .story)

        _ = testReducer.reduce(into: &state, action: .dismiss())
        XCTAssertNil(state.route)

        _ = testReducer.reduce(into: &state, action: .enter(into: .context("Context")))
        XCTAssertEqual(state.route?.action, .enterInto(.default))
        XCTAssertEqual(state.route?.route, .context("Context"))
    }
}

struct TestState: NavigationState {
    var route: RouteIntent<TestRoute>?
}

enum TestAction: NavigationAction {
    case route(RouteIntent<TestRoute>?)
}

enum TestRoute: NavigationRoute {

    case test
    case story
    case context(String)

    func destination(in store: Store<TestState, TestAction>) -> some View {
        Text(String(describing: self))
    }
}

struct TestReducer: ReducerProtocol {

    typealias State = TestState
    typealias Action = TestAction

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .route(let route):
                state.route = route
                return .none
            }
        }
    }
}
