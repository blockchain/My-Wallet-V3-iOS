// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import SwiftUI

/// An intent of navigation used to determine the route and the action performed to arrive there
public struct RouteIntent<R: NavigationRoute>: Hashable {

    public enum Action: Hashable {

        /// A navigation action that continues a user-journey by navigating to a new screen.
        case navigateTo

        /// A navigation action that enters a new user journey context, on iOS this will present a modal,
        /// on macOS it will show a new screen and on watchOS it will enter into a new screen entirely.
        case enterInto(EnterIntoContext = .default)
    }

    public var route: R
    public var action: Action

    public init(route: R, action: RouteIntent<R>.Action) {
        self.route = route
        self.action = action
    }
}

public struct EnterIntoContext: OptionSet, Hashable {

    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    public static let fullScreen = EnterIntoContext(rawValue: 1 << 0)
    public static let destinationEmbeddedIntoNavigationView = EnterIntoContext(rawValue: 1 << 1)

    public static let all: EnterIntoContext = [.fullScreen, .destinationEmbeddedIntoNavigationView]
    public static let `default`: EnterIntoContext = [.destinationEmbeddedIntoNavigationView]
    public static let none: EnterIntoContext = []
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

    public static func dismiss() -> Self {
        .route(nil)
    }

    public static func navigate(to route: RouteType) -> Self {
        .route(.navigate(to: route))
    }

    public static func enter(into route: RouteType, context: EnterIntoContext = .default) -> Self {
        .route(.enter(into: route, context: context))
    }
}

extension RouteIntent {

    public static func navigate(to route: R) -> Self {
        .init(route: route, action: .navigateTo)
    }

    public static func enter(into route: R, context: EnterIntoContext = .default) -> Self {
        .init(route: route, action: .enterInto(context))
    }
}

private class NoEnvironmentObject: ObservableObject {}

extension View {

    @ViewBuilder
    public func navigationRoute<State: NavigationState>(
        in store: Store<State, State.RouteType.Action>
    ) -> some View {
        navigationRoute(State.RouteType.self, in: store, environmentObject: NoEnvironmentObject())
    }

    @ViewBuilder
    public func navigationRoute<Route: NavigationRoute>(
        _ route: Route.Type = Route.self, in store: Store<Route.State, Route.Action>
    ) -> some View {
        modifier(NavigationRouteViewModifier<Route, NoEnvironmentObject>(store, NoEnvironmentObject()))
    }

    @ViewBuilder
    public func navigationRoute<State: NavigationState>(
        in store: Store<State, State.RouteType.Action>,
        environmentObject: (some ObservableObject)?
    ) -> some View {
        navigationRoute(State.RouteType.self, in: store, environmentObject: environmentObject)
    }

    @ViewBuilder
    public func navigationRoute<Route: NavigationRoute, EnvironmentObject: ObservableObject>(
        _ route: Route.Type = Route.self,
        in store: Store<Route.State, Route.Action>,
        environmentObject: EnvironmentObject?
    ) -> some View {
        modifier(NavigationRouteViewModifier<Route, EnvironmentObject>(store, environmentObject))
    }
}

extension EffectPublisher where Action: NavigationAction {

    /// A navigation effect to continue a user-journey by navigating to a new screen.
    public static func dismiss() -> Self {
        EffectPublisher(value: .dismiss())
    }

    /// A navigation effect to continue a user-journey by navigating to a new screen.
    public static func navigate(to route: Output.RouteType) -> Self {
        EffectPublisher(value: .navigate(to: route))
    }

    /// A navigation effect that enters a new user journey context.
    public static func enter(into route: Output.RouteType, context: EnterIntoContext = .default) -> Self {
        EffectPublisher(value: .enter(into: route, context: context))
    }
}

/// A modifier to create NavigationLink and sheet views ahead of time
public struct NavigationRouteViewModifier<Route: NavigationRoute, EnvironmentObject: ObservableObject>: ViewModifier {

    @BlockchainApp var app

    public typealias State = Route.State
    public typealias Action = Route.Action

    public let store: Store<State, Action>
    private let environmentObject: EnvironmentObject?

    @ObservedObject private var viewStore: ViewStore<RouteIntent<Route>?, Action>

    @SwiftUI.State private var intent: Identified<UUID, RouteIntent<Route>>?
    @SwiftUI.State private var isReady: Identified<UUID, RouteIntent<Route>>?

    public init(_ store: Store<State, Action>, _ environmentObject: EnvironmentObject?) {
        self.store = store
        self.environmentObject = environmentObject
        self.viewStore = ViewStore(store.scope(state: \.route))
    }

    public func body(content: Content) -> some View {
        content
            .background(routing)
            .onReceive(viewStore.publisher) { state in
                guard state != intent?.value else { return }
                intent = state.map { .init($0, id: UUID()) }
            }
    }

    @ViewBuilder private var routing: some View {
        if let intent {
            create(intent)
                .inserting(intent, into: $isReady)
        }
    }

    @ViewBuilder private func create(_ intent: Identified<UUID, RouteIntent<Route>>) -> some View {
        let binding = viewStore.binding(
            get: { $0 },
            send: Action.route
        )
        switch intent.value.action {
        case .navigateTo:
            PrimaryNavigationLink(
                destination: intent.value.route.destination(in: store).environmentObject(environmentObject),
                isActive: Binding(binding, to: intent, isReady: $isReady),
                label: EmptyView.init
            )
        case .enterInto(let context) where context.contains(.fullScreen):
            #if os(macOS)
            Color.clear
                .sheet(
                    isPresented: Binding(binding, to: intent, isReady: $isReady),
                    content: {
                        if context.contains(.destinationEmbeddedIntoNavigationView) {
                            PrimaryNavigationView { intent.value.route.destination(in: store) }.environmentObject(environmentObject)
                        } else {
                            intent.value.route.destination(in: store).environmentObject(environmentObject)
                        }
                    }
                )
            #else
            Color.clear
                .fullScreenCover(
                    isPresented: Binding(binding, to: intent, isReady: $isReady),
                    content: {
                        if context.contains(.destinationEmbeddedIntoNavigationView) {
                            PrimaryNavigationView { intent.value.route.destination(in: store) }.environmentObject(environmentObject)
                        } else {
                            intent.value.route.destination(in: store).environmentObject(environmentObject)
                        }
                    }
                )
            #endif

        case .enterInto(let context):
            Color.clear
                .sheet(
                    isPresented: Binding(binding, to: intent, isReady: $isReady),
                    content: {
                        if context.contains(.destinationEmbeddedIntoNavigationView) {
                            PrimaryNavigationView { intent.value.route.destination(in: store) }.environmentObject(environmentObject)
                        } else {
                            intent.value.route.destination(in: store).environmentObject(environmentObject)
                        }
                    }
                )
        }
    }
}

extension View {

    @ViewBuilder
    fileprivate func environmentObject(_ object: (some ObservableObject)?) -> some View {
        if let object {
            environmentObject(object)
        } else {
            self
        }
    }
}

extension View {

    @ViewBuilder fileprivate func inserting<E>(
        _ element: E,
        into binding: Binding<E?>
    ) -> some View where E: Hashable {
        onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(15)) { binding.wrappedValue = element }
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

extension Reducer where Action: NavigationAction, State: NavigationState {
    /// Returns a reducer that applies ``NavigationAction`` mutations to `NavigationState` after running this
    /// reducer's logic.
    public func routing() -> Self {
        Self { state, action, environment in
            guard let route = (/Action.route).extract(from: action)
            else {
                return self.run(&state, action, environment)
            }

            defer { state.route = route as? RouteIntent<State.RouteType> }
            return self.run(&state, action, environment)
        }
    }
}
