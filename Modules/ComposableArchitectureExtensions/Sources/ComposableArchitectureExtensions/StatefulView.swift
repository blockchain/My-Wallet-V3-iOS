// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI

// A few variants of `StatefulView(...)` are provided to assist in wrapping composable
// state which can be a combination of `LoadingState<T>` and `Result<Success, Failure>`.
// See `AccountPickerView.swift` and associated state for sample usage.

/// `LoadingState<Value>` stateful view
///
/// States handled:
/// `.loaded(Value)`
/// `.loading`
///
/// See example usage in `AccountPickerView.swift`
///
/// - Parameters:
///   - store: Store scoped to your `LoadingState<Value>` state.
///   - loadedAction: Pullback converting Loaded action to store action
///   - loadingAction: Pullback converting Loading action to store action
///   - loaded: View displayed when state is loaded
///   - loading: View displayed when state is loading
/// - Returns: A SwiftUI view
@ViewBuilder public func StatefulView<
    Value,
    Action,
    LoadedAction,
    LoadingAction
>(
    store: Store<LoadingState<Value>, Action>,
    loadedAction: @escaping (LoadedAction) -> Action,
    loadingAction: @escaping (LoadingAction) -> Action,
    @ViewBuilder loaded: @escaping (Store<Value, LoadedAction>) -> some View,
    @ViewBuilder loading: @escaping (Store<Void, LoadingAction>) -> some View
) -> some View {
    LoadingSwitchView(
        store: store,
        loadedAction: loadedAction,
        loadingAction: loadingAction,
        loaded: loaded,
        loading: loading
    )
}

/// `Result<Success, Failure>` stateful view
///
/// States handled:
/// `.success(Success)`
/// `.failure(Failure)`
///
/// See example usage in `AccountPickerView.swift`
///
/// - Parameters:
///   - store: Store scoped to your `Result<Success, Failure>` state.
///   - successAction: Pullback converting Success action to store action
///   - failureAction: Pullback converting Failure action to store action
///   - success: View displayed when state is success
///   - failure: View displayed when state is failure
/// - Returns: A SwiftUI view
@ViewBuilder public func StatefulView<
    Success,
    Failure: Error,
    Action,
    SuccessAction,
    FailureAction
>(
    store: Store<Result<Success, Failure>, Action>,
    successAction: @escaping (SuccessAction) -> Action,
    failureAction: @escaping (FailureAction) -> Action,
    @ViewBuilder success: @escaping (Store<Success, SuccessAction>) -> some View,
    @ViewBuilder failure: @escaping (Store<Failure, FailureAction>) -> some View
) -> some View {
    ResultSwitchView(
        store: store,
        successAction: successAction,
        failureAction: failureAction,
        success: success,
        failure: failure
    )
}

/// `LoadingState<Result<Success, Failure>>` stateful view
///
/// States handled:
/// `.loaded(.success(Success))`
/// `.loaded(.failure(Failure))`
/// `.loading`
///
/// See example usage in `AccountPickerView.swift`
///
/// - Parameters:
///   - store: Store scoped to your `LoadingState<Result<Success, Failure>>` state.
///   - loadedAction: Pullback converting Loaded action to store action
///   - loadingAction: Pullback converting Loading action to store action
///   - successAction: Pullback converting Success action to Loaded action
///   - failureAction: Pullback converting Failure action to Loaded action
///   - loading: View displayed when state is loading
///   - success: View displayed when state is loaded successfully
///   - failure: View displayed when state is loaded with error
/// - Returns: A SwiftUI view
@ViewBuilder public func StatefulView<
    Success,
    Failure: Error,
    Action,
    LoadedAction,
    LoadingAction,
    SuccessAction,
    FailureAction
>(
    store: Store<LoadingState<Result<Success, Failure>>, Action>,
    loadedAction: @escaping (LoadedAction) -> Action,
    loadingAction: @escaping (LoadingAction) -> Action,
    successAction: @escaping (SuccessAction) -> LoadedAction,
    failureAction: @escaping (FailureAction) -> LoadedAction,
    @ViewBuilder loading: @escaping (Store<Void, LoadingAction>) -> some View,
    @ViewBuilder success: @escaping (Store<Success, SuccessAction>) -> some View,
    @ViewBuilder failure: @escaping (Store<Failure, FailureAction>) -> some View
) -> some View {
    LoadingSwitchView(
        store: store,
        loadedAction: loadedAction,
        loadingAction: loadingAction,
        loaded: { store in
            ResultSwitchView(
                store: store,
                successAction: successAction,
                failureAction: failureAction,
                success: success,
                failure: failure
            )
        },
        loading: loading
    )
}

// MARK: - Private

/// An internal helper view for wrapping a state in the form `LoadingState<Value>`.
///
/// # Example:
/// ```
/// LoadingSwitchView(
///     store: store.scope(state: \.rows),
///     loadedAction: AccountPickerAction.rowsLoaded,
///     loadingAction: AccountPickerAction.rowsLoading,
///     loaded: { store in
///         ContentView(store)
///     },
///     loading: { _ in
///         LoadingStateView(title: "Loading")
///     }
/// )
/// ```
private struct LoadingSwitchView<
    Value,
    Action,
    LoadedAction,
    LoadingAction,
    LoadedView: View,
    LoadingView: View
>: View {
    let store: Store<LoadingState<Value>, Action>
    let loadedAction: (LoadedAction) -> Action
    let loadingAction: (LoadingAction) -> Action
    let loaded: (Store<Value, LoadedAction>) -> LoadedView
    let loading: (Store<Void, LoadingAction>) -> LoadingView

    var body: some View {
        SwitchStore(store) { state in
            switch state {
            case .loaded:
                CaseLet(/LoadingState<Value>.loaded, action: loadedAction, then: loaded)
            case .loading:
                CaseLet(/LoadingState<Value>.loading, action: loadingAction, then: loading)
            }
        }
    }
}

/// An internal helper view for wrapping a state in the form `Result<Success, Failure>`.
///
/// # Example:
/// ```
/// ResultSwitchView(
///     store: store,
///     successAction: LoadedRowsAction.success,
///     failureAction: LoadedRowsAction.failure,
///     success: { store in
///         contentView(store: store, header: viewStore.header)
///     },
///     failure: { _ in
///         ErrorStateView(title: "Failure")
///     }
/// )
/// ```
private struct ResultSwitchView<
    Success,
    Failure: Error,
    Action,
    SuccessAction,
    FailureAction,
    SuccessView: View,
    FailureView: View
>: View {
    let store: Store<Result<Success, Failure>, Action>
    let successAction: (SuccessAction) -> Action
    let failureAction: (FailureAction) -> Action
    let success: (Store<Success, SuccessAction>) -> SuccessView
    let failure: (Store<Failure, FailureAction>) -> FailureView

    var body: some View {
        SwitchStore(store) { state in
            switch state {
            case .success:
                CaseLet(/Result<Success, Failure>.success, action: successAction, then: success)
            case .failure:
                CaseLet(/Result<Success, Failure>.failure, action: failureAction, then: failure)
            }
        }
    }
}
