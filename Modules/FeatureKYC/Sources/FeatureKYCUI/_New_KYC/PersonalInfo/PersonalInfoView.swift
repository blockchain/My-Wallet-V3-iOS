// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureFormDomain
import FeatureFormUI
import Localization
import SwiftUI

private typealias LocalizedStrings = LocalizationConstants.NewKYC.Steps.PersonalInfo

struct PersonalInfoView: View {

    let store: Store<PersonalInfo.State, PersonalInfo.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            PrimaryForm(
                form: viewStore.binding(\.$form),
                submitActionTitle: LocalizedStrings.submitActionTitle,
                submitActionLoading: viewStore.formSubmissionState == .loading,
                submitAction: {
                    viewStore.send(.submit)
                },
                submitButtonMode: .onlyEnabledWhenAllAnswersValid,
                fieldConfiguration: { _ in
                        .init(textAutocorrectionType: .no)
                },
                headerIcon: {
                    headerIcon
                }
            )
            .primaryNavigation(
                leading: {
                    Button {
                        viewStore.send(.close)
                    } label: {
                        Icon.chevronLeft
                            .color(.semantic.primary)
                            .frame(width: 16, height: 16)
                    }
                },
                trailing: {
                    let isValid = viewStore.isValidForm
                    Button {
                        viewStore.send(.submit)
                    } label: {
                        Text(LocalizedStrings.submitActionTitle)
                            .typography(.paragraph2)
                            .foregroundColor(
                                isValid ? .semantic.primary : .semantic.primary.opacity(0.4)
                            )
                    }
                    .disabled(!isValid)
                }
            )
            .onAppear {
                viewStore.send(.onViewAppear)
            }
            .background(Color.semantic.light.ignoresSafeArea())
        }
    }

    var headerIcon: some View {
        ZStack {
            Circle()
                .fill(Color.semantic.background)
                .frame(width: 88)
            Icon.user
                .color(.semantic.title)
                .frame(width: 58.pt, height: 58.pt)
        }
    }
}

struct PersonalInfoView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            PrimaryNavigationView {
                PersonalInfoView(store: .emptyPreview)
            }
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.navigationBarColor, Color.semantic.light)

            PrimaryNavigationView {
                PersonalInfoView(store: .filledPreview)
            }
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.navigationBarColor, Color.semantic.light)
        }
    }
}
