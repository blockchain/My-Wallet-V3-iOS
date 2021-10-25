// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI

/// An intent of navigation used to determine the route and the action performed to arrive there
public struct RouteIntent<R: NavigationRoute>: Hashable {

    public enum Action: Hashable {

        /// A navigation action that continues a user-journey by navigating to a new screen.
        case navigateTo

        /// A navigation action that enters a new user journey context, on iOS this will present a modal,
        /// on macOS it will show a new screen and on watchOS it will enter into a new screen entirely.
        case enterInto(fullScreen: Bool = false)

        /// A navigation action that enters a new user journey context, on iOS this will present a modal,
        /// on macOS it will show a new screen and on watchOS it will enter into a new screen entirely.
        /// This will **not** wrap the view in a `NavigationView`. This may not be necessary long term,
        /// but it is necessary for the TxFlow.
        case sheet(fullScreen: Bool = false)
    }

    public var route: R
    public var action: Action
}

/// A specfication of a route and how it maps to the destination screen
public protocol NavigationRoute: Hashable {

    associatedtype Destination: View
    associatedtype State: NavigationState where State.RouteType == Self
    associatedtype Action: NavigationAction where Action.RouteType == Self

    func destination(in store: Store<State, Action>) -> Destination
}

/// A piece of state that defines a route
public protocol NavigationState: Equatable {
    associatedtype RouteType: NavigationRoute where RouteType.State == Self

    var route: RouteIntent<RouteType>? { get set }
}

/// An action which can fire a new route intent
public protocol NavigationAction {
    associatedtype RouteType: NavigationRoute where RouteType.Action == Self
    static func route(_ route: RouteIntent<RouteType>?) -> Self
}

extension NavigationRoute {

    public var label: String {
        Mirror(reflecting: self).children.first?.label
            ?? String(describing: self)
    }
}

extension NavigationAction {

    public static func navigate(to route: RouteType?) -> Self {
        .route(route.map { RouteIntent(route: $0, action: .navigateTo) })
    }

    public static func enter(into route: RouteType?) -> Self {
        enter(into: route, fullScreen: false)
    }

    public static func sheet(into route: RouteType?) -> Self {
        sheet(into: route, fullScreen: false)
    }

    public static func sheet(into route: RouteType?, fullScreen: Bool) -> Self {
        .route(route.map { RouteIntent(route: $0, action: .sheet(fullScreen: fullScreen)) })
    }

    public static func enter(into route: RouteType?, fullScreen: Bool) -> Self {
        .route(route.map { RouteIntent(route: $0, action: .enterInto(fullScreen: fullScreen)) })
    }
}

extension View {

    @ViewBuilder
    public func navigationRoute<State: NavigationState>(
        in store: Store<State, State.RouteType.Action>
    ) -> some View {
        navigationRoute(State.RouteType.self, in: store)
    }

    @ViewBuilder
    public func navigationRoute<Route: NavigationRoute>(
        _ route: Route.Type = Route.self, in store: Store<Route.State, Route.Action>
    ) -> some View {
        modifier(NavigationRouteViewModifier<Route>(store))
    }
}

extension Effect where Output: NavigationAction {

    /// A navigation effect to continue a user-journey by navigating to a new screen.
    public static func navigate(to route: Output.RouteType?) -> Self {
        Effect(value: .navigate(to: route))
    }

    /// A navigation effect that enters a new user journey context.
    public static func enter(into route: Output.RouteType?, fullScreen: Bool = false) -> Self {
        Effect(value: .enter(into: route, fullScreen: fullScreen))
    }

    /// A navigation effect that enters a new user journey context.
    public static func sheet(into route: Output.RouteType?, fullScreen: Bool = false) -> Self {
        Effect(value: .sheet(into: route))
    }
}

/// A modifier to create NavigationLink and sheet views ahead of time
public struct NavigationRouteViewModifier<Route: NavigationRoute>: ViewModifier {

    public typealias State = Route.State
    public typealias Action = Route.Action

    public let store: Store<State, Action>

    @ObservedObject private var viewStore: ViewStore<RouteIntent<Route>?, Action>

    @SwiftUI.State private var intent: Identified<UUID, RouteIntent<Route>>?
    @SwiftUI.State private var isReady: Identified<UUID, RouteIntent<Route>>?

    public init(_ store: Store<State, Action>) {
        self.store = store
        viewStore = ViewStore(store.scope(state: \.route))
    }

    public func body(content: Content) -> some View {
        content.background(
            Group {
                if let intent = intent {
                    create(intent).inserting(intent, into: $isReady)
                }
            }
        )
        .onReceive(viewStore.publisher) { state in
            guard state != intent?.value else { return }
            intent = state.map { .init($0, id: UUID()) }
        }
    }

    @ViewBuilder private func create(_ intent: Identified<UUID, RouteIntent<Route>>) -> some View {
        let binding = viewStore.binding(
            get: { $0 },
            send: Action.route
        )
        switch intent.value.action {
        case .navigateTo:
            NavigationLink(
                destination: intent.value.route.destination(in: store),
                isActive: Binding(binding, to: intent, isReady: $isReady),
                label: EmptyView.init
            )

        case .sheet(fullScreen: false):
            EmptyView()
                .sheet(
                    isPresented: Binding(binding, to: intent, isReady: $isReady),
                    content: {
                        intent.value.route.destination(in: store)
                    }
                )
        case .sheet(fullScreen: true):
            #if os(macOS)
            EmptyView()
                .sheet(
                    isPresented: Binding(binding, to: intent, isReady: $isReady),
                    content: {
                        intent.value.route.destination(in: store)
                    }
                )
            #else
            EmptyView()
                .fullScreenCover(
                    isPresented: Binding(binding, to: intent, isReady: $isReady),
                    content: {
                        intent.value.route.destination(in: store)
                    }
                )
            #endif

        case .enterInto(fullScreen: false):
            EmptyView()
                .sheet(
                    isPresented: Binding(binding, to: intent, isReady: $isReady),
                    content: {
                        NavigationView { intent.value.route.destination(in: store) }
                    }
                )

        case .enterInto(fullScreen: true):
            #if os(macOS)
            EmptyView()
                .sheet(
                    isPresented: Binding(binding, to: intent, isReady: $isReady),
                    content: {
                        NavigationView { intent.value.route.destination(in: store) }
                    }
                )
            #else
            EmptyView()
                .fullScreenCover(
                    isPresented: Binding(binding, to: intent, isReady: $isReady),
                    content: {
                        NavigationView { intent.value.route.destination(in: store) }
                    }
                )
            #endif
        }
    }
}

extension View {

    @ViewBuilder fileprivate func inserting<E>(
        _ element: E,
        into binding: Binding<E?>
    ) -> some View where E: Hashable {
        onAppear {
            DispatchQueue.main.async { binding.wrappedValue = element }
        }
    }
}

extension Binding where Value == Bool {

    fileprivate init<E: Equatable>(
        _ source: Binding<E?>,
        to element: Identified<UUID, E>,
        isReady ready: Binding<Identified<UUID, E>?>
    ) {
        self.init(
            get: { source.wrappedValue == element.value && ready.wrappedValue == element },
            set: { source.wrappedValue = $0 ? element.value : nil }
        )
    }
}
