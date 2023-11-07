import BlockchainUI
import SwiftUI

public struct ApplicationSubmittedView: View {

    @StateObject var object = ApplicationSubmittedObject()
    @Environment(\.dismiss) var dismiss

    var completion: () -> Void

    public var body: some View {
        VStack {
            VStack(spacing: 24.pt) {
                Icon.user
                    .circle(backgroundColor: Color.semantic.background)
                    .color(.semantic.title)
                    .extraLarge()
                    .padding(8.pt)
                    .overlay(
                        alignment: .bottomTrailing,
                        content: {
                            Group {
                                if object.state.isLoading {
                                    ProgressView()
                                        .progressViewStyle(.indeterminate)
                                        .padding(4.pt)
                                } else {
                                    Icon.clockFilled
                                        .color(.semantic.muted)
                                        .scaleToFit()
                                }
                            }
                            .background(Circle().fill(Color.semantic.light))
                            .frame(width: 44.pt)
                        }
                    )

                VStack(spacing: 16.pt) {
                    Text(L10n.applicationSubmitted)
                        .typography(.title3)
                        .foregroundTexture(.semantic.title)
                    Text(L10n.receivedYourInformation)
                    .typography(.body1)
                    .foregroundTexture(.semantic.text)
                    if object.state.isIdle || object.state.isLoading {
                        Text(L10n.couldTake60Seconds)
                        .typography(.body1)
                        .foregroundTexture(.semantic.text)
                    } else {
                        Text(L10n.wellNotifyYou)
                        .typography(.body1)
                        .foregroundTexture(.semantic.text)
                    }
                }
                .padding(.horizontal)
                .multilineTextAlignment(.center)
            }
            .padding(.top, 90.pt)
            .frame(maxHeight: .infinity, alignment: .top)
            VStack {
                if object.state.isIdle || object.state.isLoading {
                    EmptyView()
                } else {
                    PrimaryButton(
                        title: L10n.goToDashboard,
                        action: {
                            dismiss()
                        }
                    )
                    .padding(.horizontal)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.semantic.light)
        .task {
            switch await object.waitForCompletion() {
            case .success: completion()
            default: break
            }
        }
    }
}

public class ApplicationSubmittedObject: ObservableObject {

    @Dependency(\.app) var app
    @Dependency(\.KYCOnboardingService) var KYCOnboardingService

    @Published var state: AsyncState<Void, Error> = .idle

    func waitForCompletion() async -> AsyncState<Void, Error> {
        do {
            state = .loading
            for await flow in KYCOnboardingService.flow() where flow.next_action.slug == .pendingKYC {
                try await Task.sleep(nanoseconds: 3 * NSEC_PER_SEC)
            }
            state = .success
        } catch {
            state = .failure(error)
        }
        return state
    }
}

struct ApplicationSubmittedView_Preview: PreviewProvider {
    static var previews: some View {
        ApplicationSubmittedView { print(#fileID) }
    }
}
