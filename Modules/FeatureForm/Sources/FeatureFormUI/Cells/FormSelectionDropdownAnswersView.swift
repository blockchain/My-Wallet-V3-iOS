// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureFormDomain
import Localization
import SwiftUI

enum FormSelectionDropdownAnswersSelectionMode {
    case single
    case multi
}

struct FormSelectionDropdownAnswersView: View {

    let title: String
    let subtitle: String?
    let selectionMode: FormSelectionDropdownAnswersSelectionMode
    @Binding var answers: [FormAnswer]
    @Binding var showAnswerState: Bool
    @State private var selectionPanelOpened: Bool = false
    let fieldConfiguration: PrimaryFormFieldConfiguration

    var body: some View {
        VStack {
            let selectedAnswers = answers.filter { $0.checked == true }
            HStack(spacing: Spacing.padding1) {
                let selectedAnswersText = selectedAnswers.compactMap(\.text).joined(separator: ", ")
                Text(selectedAnswersText)
                    .typography(.paragraph2)
                    .foregroundColor(.semantic.body)

                Spacer()

                Icon.chevronDown
                    .color(.semantic.muted)
                    .frame(width: 24, height: 24)
            }
            .padding(Spacing.padding2)
            .background(
                RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                    .stroke(Color.semantic.light)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                // hide current keybaord if presented,
                // delay needed to wait until keyboard is dismissed
                stopEditing()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectionPanelOpened.toggle()
                }
            }

            switch selectionMode {
            case .single:
                if let selectedAnswer = selectedAnswers.first,
                   selectedAnswer.children?.isEmpty == false
                {
                    if let index = answers.firstIndex(of: selectedAnswer) {
                        FormRecursiveAnswerView(
                            title: title,
                            answer: $answers[index],
                            showAnswerState: $showAnswerState,
                            fieldConfiguration: fieldConfiguration
                        ) {
                            EmptyView()
                        }
                    }
                }
            case .multi:
                EmptyView()
            }

            if let answer = answers.first,
               let bottomButton = fieldConfiguration(answer.id).bottomButton
            {
                FormAnswerBottomButtonView(
                    leadingPrefixText: bottomButton.leadingPrefixText,
                    title: bottomButton.title,
                    action: bottomButton.action
                )
                .padding(.top, 12.pt)
            }
        }
        .sheet(isPresented: $selectionPanelOpened) {
            FormSelectionDropdownAnswersListView(
                title: title,
                subtitle: subtitle,
                selectionMode: selectionMode,
                answers: $answers,
                selectionPanelOpened: $selectionPanelOpened
            )
        }
    }
}

struct FormSelectionDropdownAnswersListView: View {

    let title: String
    let subtitle: String?
    let selectionMode: FormSelectionDropdownAnswersSelectionMode
    @Binding var answers: [FormAnswer]
    @Binding var selectionPanelOpened: Bool
    @State private var searchText = ""

    var searchResults: [FormAnswer] {
        if searchText.isEmpty {
             return answers
         } else {
             return answers.filter { $0.text?.lowercased().contains(searchText.lowercased()) ?? false }
         }
     }

    var body: some View {
        NavigationView {
            ScrollView {
                let selectedIndex = answers.firstIndex(
                    where: { $0.checked == true }
                )
                if #available(iOS 15.0, *) {
                    ForEach(searchResults, id: \.self) { answer in
                        FormDropdownAnswerSelectionView(answer: answer) {
                            switch selectionMode {
                            case .single:
                                if let index = selectedIndex {
                                    answers[index].checked = false
                                }
                                var answer = answer
                                answer.checked = false
                                if let value = $answers.first(where: { $0.wrappedValue == answer }) {
                                    value.wrappedValue.checked = true
                                }
                                selectionPanelOpened.toggle()
                            case .multi:
                                if let value = $answers.first(where: { $0.wrappedValue == answer }) {
                                    value.wrappedValue.checked = !(value.wrappedValue.checked ?? false)
                                }
                            }
                        }
                        PrimaryDivider()
                    }
                } else {
                    ForEach($answers) { answer in
                        FormDropdownAnswerSelectionView(answer: answer.wrappedValue) {
                            switch selectionMode {
                            case .single:
                                if let index = selectedIndex {
                                    answers[index].checked = false
                                }
                                answer.wrappedValue.checked = true
                                selectionPanelOpened.toggle()
                            case .multi:
                                answer.wrappedValue.checked = !(answer.wrappedValue.checked ?? false)
                            }
                        }
                        PrimaryDivider()
                    }
                }
            }
            .searchableIfAvailable(
                text: $searchText,
                shouldShow: answers.count > 10
            )
            .padding(.vertical, Spacing.padding1)
            .padding(.horizontal, Spacing.padding2)
            .background(Color.semantic.background)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Spacer()
                        Text(title).typography(.body2)
                        Spacer(minLength: 1)
                        subtitle.map {
                            Text($0).typography(.caption1)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        switch selectionMode {
        case .single:
            EmptyView()
        case .multi:
            primaryButton
        }
    }

    private var primaryButton: some View {
        PrimaryButton(
            title: LocalizationConstants.MultiSelection.Buttons.done
        ) {
            selectionPanelOpened.toggle()
        }
        .frame(alignment: .bottom)
        .padding([.horizontal, .bottom])
        .background(
            Rectangle()
                .fill(.white)
                .backgroundWithWhiteShadow
        )
    }
}

extension View {
    public func searchableIfAvailable(
        text: Binding<String>,
        shouldShow: Bool
    ) -> some View {
        if #available(iOS 15.0, *), shouldShow {
            return AnyView(
                searchable(
                    text: text,
                    placement: .navigationBarDrawer(displayMode: .always)
                )
            )
        } else {
            return AnyView(self)
        }
    }
}

private struct FormDropdownAnswerSelectionView: View {

    let answer: FormAnswer
    let onSelection: () -> Void

    var body: some View {
        let isSelected = answer.checked == true
        HStack(spacing: Spacing.padding1) {
            Text(answer.text ?? "")
                .typography(.paragraph2)
                .multilineTextAlignment(.leading)

            Spacer()

            if isSelected {
                Icon.checkCircle
                    .color(.semantic.primary)
                    .frame(width: 16, height: 16)
            }
        }
        .padding(Spacing.padding2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Spacing.buttonBorderRadius)
                .fill(isSelected ? Color.semantic.blueBG : Color.semantic.background)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onSelection()
        }
    }
}

struct FormSelectionDropdownAnswersView_Previews: PreviewProvider {

    static var previews: some View {
        PreviewHelper(
            answers: [
                FormAnswer(
                    id: "a1",
                    type: .selection,
                    text: "Answer 1",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: nil
                ),
                FormAnswer(
                    id: "a2",
                    type: .selection,
                    text: "Answer 2",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: nil
                )
            ],
            showAnswerState: false
        )

        PreviewHelper(
            answers: [
                FormAnswer(
                    id: "a1",
                    type: .selection,
                    text: "Answer 1",
                    children: [
                        FormAnswer(
                            id: "a1-a1",
                            type: .openEnded,
                            text: "Nested Question",
                            children: nil,
                            input: nil,
                            hint: "Provide info",
                            regex: nil,
                            checked: nil
                        )
                    ],
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: true
                ),
                FormAnswer(
                    id: "a2",
                    type: .selection,
                    text: "Answer 2",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: nil
                )
            ],
            showAnswerState: false
        )
    }

    struct PreviewHelper: View {

        @State var answers: [FormAnswer]
        @State var showAnswerState: Bool

        var body: some View {
            FormSelectionDropdownAnswersView(
                title: "Title",
                subtitle: "Subtitle",
                selectionMode: .single,
                answers: $answers,
                showAnswerState: $showAnswerState,
                fieldConfiguration: defaultFieldConfiguration
            )
            .padding()
        }
    }
}
