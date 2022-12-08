import SwiftUI

struct BlockchainNamespaceLifecycleViewModifier<T: Equatable>: ViewModifier {

    @BlockchainApp var app
    @Environment(\.context) var context

    let tag: L & I_blockchain_ui_type_element
    let update: T

    func body(content: Content) -> some View {
        content.onAppear {
            app.post(event: tag.lifecycle.event.did.enter.key(to: context), context: context)
        }
        .onChange(of: update) { _ in
            app.post(event: tag.lifecycle.event.did.update.key(to: context), context: context)
        }
        .onDisappear {
            app.post(event: tag.lifecycle.event.did.exit.key(to: context), context: context)
        }
    }
}

extension View {

    @ViewBuilder
    @warn_unqualified_access public func post(lifecycleOf element: L & I_blockchain_ui_type_element, update change: some Equatable = 0) -> some View {
        modifier(BlockchainNamespaceLifecycleViewModifier(tag: element, update: change))
    }
}
