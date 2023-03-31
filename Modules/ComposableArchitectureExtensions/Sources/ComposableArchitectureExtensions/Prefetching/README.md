# Prefetching

A composable collection of State, Action, Environment, and Reducer for prefetching content in scrollable lists.

## How-to

1. Add `PrefetchingState` to your existing state

```swift
struct ExampleState: Equatable {
    var prefetching: PrefetchingState()
    ...
```

2. Add `PrefetchingAction` to your existing action

```swift
enum ExampleAction {
    case prefetching(PrefetchingAction)
    ...
```

2. Combine `PrefetchingReducer` with your reducer, implementing the `.fetch` case to run your fetching.

Remember to also update `validIndices` to get fetch ahead/behind support.

```swift
let exampleReducer = Reducer<ExampleState, ExampleAction, ExampleEnvironment> { state, action, environment in
    switch action {
    case .update(items: let items):
        state.prefetching.validIndices = items.indicies
        state.items = items
        return .none

    case .prefetching(.fetch(indices: let indices)):
        // Fetch your content as desired!
        return environment
                   .fetch(indices)
                   .catchToEffect()
    }
}
.combined(
    with: PrefetchingReducer(
        state: \ExampleState.prefetching,
        action: /ExampleAction.prefetching,
        environment: { .init(mainQueue: $0.mainQueue) }
    )
)
```

3. Send the `.onAppear` and `.onDisappear` actions as appropriate:

```swift
ForEach(items.index()) { index, item in
    ItemRow(item)
        .onAppear { viewStore.send(.prefetching(.onAppear(index))) }
        .onDisappear { viewStore.send(.prefetching(.onDisappear(index))) }
}
```

4. Enjoy prefetching!

Customize the `debounce` and `fetchMargin` when initializing state if desired.

```swift
PrefetchingState(
    debounce: 2.0, // Real slow till things load!
    fetchMargin: 100 // Fetch a ton ahead and behind visible items
)
```

If you want to requeue for fetching after errors, or if something is still loading, use the `requeue` action:

```swift
return EffectTask(value: .prefetching(.requeue(indices)))
```

## Future improvements:

### Repetitive Prefetching:

Making the debounce recursive, and increasing the margins with each call until all valid indices are fetched.
This would allow for eventual full loading of content if a user sits on the screen without action.

More dynamic debouncing values on first vs following calls could make for extremely snappy initial load, and slower follow ups to make scrolling maintain its framerate.
