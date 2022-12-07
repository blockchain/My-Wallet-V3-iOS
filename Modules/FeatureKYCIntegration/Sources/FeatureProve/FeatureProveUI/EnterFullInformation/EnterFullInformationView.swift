// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import BlockchainNamespace
import ComposableArchitecture
import DIKit
import ErrorsUI
import FeatureFormDomain
import FeatureFormUI
import Localization
import SwiftUI
import UIComponentsKit

struct EnterFullInformationView: View {

    private typealias LocalizedString = LocalizationConstants.EnterFullInformation

    @ObservedObject private var viewStore: ViewStore<EnterFullInformation.State, EnterFullInformation.Action>

    init(store: StoreOf<EnterFullInformation>) {
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        Group {
            switch viewStore.mode {
            case .info:
                content
            case .verifyingPhone:
                verifyingPhone
            case .loading:
                LoadingView(title: LocalizedString.loadingTitle)
            case .restartingVerificationLoading:
                LoadingView()
            case .error(let uxError):
                makeError(uxError: uxError)
            }
        }
        .primaryNavigation(
            title: viewStore.title,
            trailing: {
                if case .error = viewStore.mode {
                    EmptyView()
                } else {
                    IconButton(icon: .closeCirclev2) {
                        viewStore.send(.onClose)
                    }
                    .frame(width: 24.pt, height: 24.pt)
                }
            }
        )
        .hideBackButtonTitle()
        .navigationBarBackButtonHidden()
        .onAppear {
            viewStore.send(.onAppear)
        }
        .onDisappear {
            viewStore.send(.didDisappear)
        }
        .onAppEnteredBackground {
            viewStore.send(.didEnteredBackground)
        }
        .onAppEnteredForeground {
            viewStore.send(.didEnterForeground)
        }
    }

    private var content: some View {
        Group {
            Spacer(minLength: 24.0)
            PrimaryForm(
                form: viewStore.binding(\.$form),
                submitActionTitle: LocalizedString.Buttons.continueTitle,
                submitActionLoading: viewStore.isLoading,
                submitAction: {
                    viewStore.send(.onContinue)
                },
                submitButtonMode: .onlyEnabledWhenAllAnswersValid,
                submitButtonLocation: .attachedToBottomOfScreen(
                    footerText: LocalizedString.Footer.title,
                    hasDivider: true
                ),
                fieldConfiguration: { fieldId in
                    switch fieldId {
                    case EnterFullInformation.InputField.phone.rawValue:
                        return .phoneField
                    default:
                        return .init(textAutocorrectionType: .no)
                    }
                },
                headerIcon: {
                    headerIcon
                }
            )
        }
    }

    private var verifyingPhone: some View {
        LoadingView(
            title: LocalizedString.Body.VerifyingPhone.title,
            subtitle: LocalizedString.Body.VerifyingPhone.subttitle,
            buttonTitle: viewStore.binding(\.$restartPhoneVerificationButtonTitle),
            buttonDisabled: viewStore.binding(\.$isRestartPhoneVerificationButtonDisabled),
            buttonAction: { viewStore.send(.restartPhoneVerfication) }
        )
    }

    private func makeError(uxError: UX.Error) -> some View {
        ErrorView(
            ux: uxError,
            dismiss: {
                viewStore.send(.onDismissError)
            }
        )
    }

    var headerIcon: some View {
        Icon.user
            .color(.semantic.primary)
            .frame(width: 32.pt, height: 32.pt)
    }
}

struct EnterFullInformation_Previews: PreviewProvider {

    static var previews: some View {
        let app: AppProtocol = resolve()
        Group {
            BeginVerificationView(store: .init(
                initialState: .init(),
                reducer: BeginVerification.preview(app: app)
            )).app(app)
        }
    }
}

extension FieldConfiguation {
    fileprivate static let phoneField: FieldConfiguation = {
        .init(
            textAutocorrectionType: .no,
            keyboardType: .phonePad,
            textContentType: .telephoneNumber,
            inputPrefixConfig: .init(typography: .bodyMono, textColor: .semantic.title, spacing: 6),
            onTextChange: String.formatPhone(phone:)
        )
    }()
}

extension String {
    static func formatPhone(phone: String) -> String {
        phone
            .removeCountryCode()
            .formatMask(with: "(XXX) XXX-XXXX")
    }

    private func removeCountryCode() -> String {
        guard contains("+")
        else { return self }
        if count == 1 { return "" }

        var totalCharacters: Int = 0
        var totalDigits: Int = 0
        // all mobile phones has 10 digits, we count 10 digits from the end
        // add take only characters with these 10 digits using suffix
        for element in reversed() {
            totalCharacters += 1
            if element.isNumber {
                totalDigits += 1
            }
            if totalDigits == 10 {
                break
            }
        }
        // add missing "(" if neded
        if suffix(totalCharacters + 1).first == "(" {
            totalCharacters += 1
        }

        return String(suffix(totalCharacters))
    }

    private func formatMask(with mask: String) -> String {
        let numbers = self.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex

        for char in mask where index < numbers.endIndex {
            if char == "X" {
                result.append(numbers[index])
                index = numbers.index(after: index)
            } else {
                result.append(char)
            }
        }
        return result
    }
}
