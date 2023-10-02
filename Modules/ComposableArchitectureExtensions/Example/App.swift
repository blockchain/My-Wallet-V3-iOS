// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import ComposableNavigation
import SwiftUI

@main
struct Demo: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView(
                    store: Store(
                        initialState: ExampleState(name: "Root"),
                        reducer: ExampleReducer()
                    )
                )
            }
        }
    }
}

struct ExampleState: Equatable, NavigationState {
    var route: RouteIntent<ExampleRoute>?
    var name: String
    var lineage: [String] = []
    var end: EndState = .init(name: "End")
}

indirect enum ExampleAction: NavigationAction {
    case route(RouteIntent<ExampleRoute>?)
    case end(EndAction)
}

enum ExampleRoute: NavigationRoute, CaseIterable {

    case a
    case b
    case c
    case end

    @ViewBuilder
    func destination(in store: Store<ExampleState, ExampleAction>) -> some View {
        let viewStore = ViewStore(store)
        switch self {
        case .a, .b, .c:
            ContentView(
                store: .init(
                    initialState: ExampleState(
                        name: String(describing: self),
                        lineage: viewStore.lineage + [viewStore.name]
                    ),
                    reducer: ExampleReducer()
                )
            )
        case .end:
            EndContentView(
                store: .init(
                    initialState: EndState(name: "End"),
                    reducer: EndReducer(
                        dismiss: { viewStore.send(.dismiss()) }
                    )
                )
            )
        }
    }
}

struct ContentView: View {

    let store: Store<ExampleState, ExampleAction>

    init(store: Store<ExampleState, ExampleAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { view in
            VStack(alignment: .leading) {
                Text(view.lineage.joined(separator: "."))
                Spacer()
                ForEach(ExampleRoute.allCases, id: \.self) { route in
                    Button("Navigate To → \(String(describing: route))") {
                        view.send(.navigate(to: route))
                    }
                }
                Spacer()
                ForEach(ExampleRoute.allCases, id: \.self) { route in
                    Button("Enter Into → \(String(describing: route))") {
                        view.send(.enter(into: route))
                    }
                }
                Spacer()
            }
            .navigationTitle(view.name)
            .navigationRoute(in: store)
        }
    }
}

struct EndState: Equatable {
    var name: String
}

enum EndAction {
    case dismiss
    case onAppear
}

struct EndContentView: View {

    let store: Store<EndState, EndAction>

    init(store: Store<EndState, EndAction>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { view in
            VStack(spacing: 24) {
                Text(view.name)
                    .onAppear {
                        view.send(.onAppear)
                    }
                Button("dismiss") {
                    view.send(.dismiss)
                }
            }
        }
    }
}

struct ExampleReducer: ReducerProtocol {
    typealias Action = ExampleAction
    typealias State = ExampleState

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .route:
                return .none
            case .end:
                return .fireAndForget { print("✅") }
            }
        }
        .routing()
    }
}

struct EndReducer: ReducerProtocol {
    typealias Action = EndAction
    typealias State = EndState

    let dismiss: () -> Void

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .dismiss:
                return .fireAndForget(dismiss)
            case .onAppear:
                return .none
            }
        }
    }
}

struct ReducerContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: Store(
                initialState: ExampleState(name: "Root"),
                reducer: ExampleReducer()
            )
        )
    }
}
