//
// This source file is part of the Plainly iOS open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import PlainlyShared
import SwiftUI

struct TaskInstructionView: View {
    let task: Study.Task
    let userDisplayableCurrentTaskIdx: Int
    /// Skips the task, or `nil` while the task cannot be skipped.
    var onSkip: (@MainActor () -> Void)?
    /// Whether skipping has to wait, e.g. for an answer that is still arriving.
    var isSkipDisabled = false
    /// Called when the sheet should be dismissed
    let onDismiss: @MainActor () -> Void

    @State private var isConfirmingSkip = false

    var body: some View {
        BottomSheet {
            VStack(spacing: 0) {
                if let instructions = task.instructions {
                    instructionsText(for: instructions)
                }
                if let onSkip {
                    skipButton(onSkip)
                }
            }
            .navigationTitle("Task \(userDisplayableCurrentTaskIdx)")
            .transforming {
                if #available(iOS 26, *), let title = task.title {
                    $0.navigationSubtitle(title)
                } else {
                    $0
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbar }
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private var toolbar: some ToolbarContent {
        ToolbarItem {
            if #available(iOS 26, *) {
                Button(role: .close) {
                    onDismiss()
                }
            } else {
                Button {
                    onDismiss()
                } label: {
                    Label("Dismiss", systemImage: "xmark")
                        .accessibilityLabel("Dismiss")
                }
            }
        }
    }
    
    private func instructionsText(for instructions: String) -> some View {
        let text = if let markdown = try? AttributedString(markdown: instructions) {
            Text(markdown)
        } else {
            Text(instructions)
        }
        return text
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(10)
            .padding()
    }

    /// Lets a participant past a task that does not apply to them, which otherwise only an answer from the chat does.
    private func skipButton(_ onSkip: @escaping @MainActor () -> Void) -> some View {
        Button {
            isConfirmingSkip = true
        } label: {
            Text("Skip This Task")
                .font(.subheadline)
                .foregroundStyle(Color(isSkipDisabled ? UIColor.tertiaryLabel : UIColor.secondaryLabel))
                .frame(minHeight: 44)
        }
        .buttonStyle(.borderless)
        .disabled(isSkipDisabled)
        .padding(.bottom)
        // Named, because the next task's sheet looks the same and offers the same button.
        .alert("Skip Task \(userDisplayableCurrentTaskIdx)?", isPresented: $isConfirmingSkip) {
            Button("Skip Task", action: onSkip)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Skip a task only if it does not apply to you or you already asked about it. You cannot go back.")
        }
    }
}
