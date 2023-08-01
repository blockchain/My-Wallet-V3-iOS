// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import Extensions
import FeatureFormDomain
import SwiftUI

struct FormMultipleSelectionAnswersView: View {

    let title: String
    @Binding var answers: [FormAnswer]
    @Binding var showAnswersState: Bool
    let fieldConfiguration: PrimaryFormFieldConfiguration

    var isStacked: Bool {
        answers.allSatisfy(\.isSelection)
    }

    var body: some View {
        if #available(iOS 16, *), isStacked {
            OverflowHStack(alignment: .leading) {
                ForEach($answers) { answer in
                    FormMultipleSelectionAnswerSingleTileView(
                        title: title,
                        answer: answer,
                        showAnswerState: $showAnswersState,
                        fieldConfiguration: fieldConfiguration
                    )
                }
            }
        } else {
            VStack(alignment: .leading, spacing: Spacing.padding1) {
                ForEach($answers) { answer in
                    view(for: answer)
                }
            }
        }
    }

    @ViewBuilder
    private func view(for answer: Binding<FormAnswer>) -> some View {
        switch answer.wrappedValue.type {
        case .date:
            FormDateDropdownAnswersView(
                title: title,
                answer: answer,
                showAnswerState: $showAnswersState
            )
        case .selection:
            FormSingleSelectionAnswerView(
                title: title,
                answer: answer,
                showAnswerState: $showAnswersState,
                fieldConfiguration: fieldConfiguration
            )
        case .openEnded:
            FormOpenEndedAnswerView(
                answer: answer,
                showAnswerState: $showAnswersState,
                fieldConfiguration: fieldConfiguration
            )
        default:
            Text(answer.wrappedValue.type.value)
                .typography(.paragraph1)
                .foregroundColor(.semantic.error)
        }
    }
}

struct FormMultipleSelectionAnswersView_Previews: PreviewProvider {

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
                    type: .openEnded,
                    text: "Answer 2",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: nil
                ),
                FormAnswer(
                    id: "a3",
                    type: .date,
                    text: "Answer 3",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: nil
                )
            ],
            showAnswersState: false
        )
        PreviewHelper(
            answers: [
                FormAnswer(
                    id: "a1",
                    type: .selection,
                    text: "💰 To Invest",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: nil
                ),
                FormAnswer(
                    id: "a2",
                    type: .selection,
                    text: "🔁 To trade",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: nil
                ),
                FormAnswer(
                    id: "a3",
                    type: .selection,
                    text: "💳 For purchases",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: nil
                ),
                FormAnswer(
                    id: "a4",
                    type: .selection,
                    text: "📲 For sending to another person",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: nil
                ),
                FormAnswer(
                    id: "a5",
                    type: .selection,
                    text: "🧳 To conduct business",
                    children: nil,
                    input: nil,
                    hint: nil,
                    regex: nil,
                    checked: nil
                )
            ],
            showAnswersState: true
        )
    }

    struct PreviewHelper: View {

        @State var answers: [FormAnswer]
        @State var showAnswersState: Bool

        var body: some View {
            FormMultipleSelectionAnswersView(
                title: "Title",
                answers: $answers,
                showAnswersState: $showAnswersState,
                fieldConfiguration: defaultFieldConfiguration
            )
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.semantic.light)
        }
    }
}
