import SwiftUI

struct BlockchainNamespaceLifecycleViewModifier<T: Equatable>: ViewModifier {

    @BlockchainApp var app
    @Environment(\.context) var context

    let tag: L & I_blockchain_ui_type_element
    let update: T
    let file: String
    let line: Int

    func body(content: Content) -> some View {
        content.onAppear {
            app.post(event: tag.lifecycle.event.did.enter.key(to: context), context: context, file: file, line: line)
        }
        .onChange(of: update) { _ in
            app.post(event: tag.lifecycle.event.did.update.key(to: context), context: context, file: file, line: line)
        }
        .onDisappear {
            app.post(event: tag.lifecycle.event.did.exit.key(to: context), context: context, file: file, line: line)
        }
    }
}

extension View {

    @ViewBuilder
    @warn_unqualified_access public func post(
        lifecycleOf element: L & I_blockchain_ui_type_element,
        update change: some Equatable = 0,
        file: String = #file,
        line: Int = #line
    ) -> some View {
        modifier(BlockchainNamespaceLifecycleViewModifier(tag: element, update: change, file: file, line: line))
    }
}
