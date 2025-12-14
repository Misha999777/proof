//
//  ProofingInterfaceView.swift
//  Proof
//
//  Created by Михайло Грошевий on 09/12/2025.
//

import SwiftUI

// MARK: - ViewModel
@Observable
class ProofreadingModel {
    var originalText: String
    var proofreadText: String = ""
    var selectedGoal: ProofingGoal = .fixGrammar
    var isLoading = false
    
    init(originalText: String) {
        self.originalText = originalText
        runProofreading()
    }
    
    func reset() {
        originalText = ""
        proofreadText = ""
    }
    
    func runProofreading() {
        guard !originalText.isEmpty && ConfigurationService.shared.isConfigured else { return }
        
        isLoading = true
        let fullPrompt = selectedGoal.promptText + "\n\n" + originalText
        
        proofread(text: fullPrompt) { [weak self] status, text in
            guard let self = self else { return }
            self.proofreadText = text
            self.isLoading = false
        }
    }
}

// MARK: - View
struct ProofreadingView: View {
    
    @Bindable var vm: ProofreadingModel
    @Binding var showSettings: Bool

    @FocusState var focused

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            Section(header:
                HStack {
                    sectionHeader("Goal")
                    Spacer()
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Settings")
                }
            ) {
                Picker("", selection: $vm.selectedGoal) {
                    ForEach(ProofingGoal.allCases) { goal in
                        Text(goal.rawValue).tag(goal)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .frame(width: 200)
            }
            
            Section(header:
                HStack {
                    sectionHeader("Original Text")
                    Spacer()
                    Button(role: .destructive) {
                        vm.reset()
                    } label: {
                        Label("Clear", systemImage: "trash")
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.borderless)
                    .help("Clear all text")
                }
            ) {
                styledEditor($vm.originalText, height: 150, isEditable: true)
                    .focused($focused)
                    .onAppear {
                        DispatchQueue.main.async {
                            focused = true
                        }
                    }
            }
            
            HStack {
                Button {
                    vm.runProofreading()
                } label: {
                    Label("Run Proofreading", systemImage: "wand.and.stars")
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.originalText.isEmpty || vm.isLoading)
                
                if vm.isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .padding(.leading, 8)
                }
            }
            
            Section(header: sectionHeader("Result")) {
                styledEditor($vm.proofreadText, height: 150, isEditable: false)
            }
            
            Divider()
            
            HStack {
                Button(role: .destructive) {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Label("Exit", systemImage: "power")
                }
                
                Spacer()
                
                Button {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(vm.proofreadText, forType: .string)
                } label: {
                    Label("Copy Result", systemImage: "doc.on.doc")
                }
                .disabled(vm.proofreadText.isEmpty)
            }
        }
        .padding(20)
    }
}

// MARK: - UI Helpers
@ViewBuilder
func sectionHeader(_ title: String) -> some View {
    Text(title)
        .font(.headline)
        .foregroundStyle(.secondary)
}

@ViewBuilder
func styledEditor(_ content: Binding<String>, height: CGFloat, isEditable: Bool) -> some View {
    MacEditor(content: content, isEditable: isEditable)
        .frame(height: height)
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
}

// MARK: - Preview
#Preview {
    struct Preview: View {

        @State var model = ProofreadingModel(originalText: "")
        @State var show = false

        var body: some View {
            ProofreadingView(vm: model, showSettings: $show)
                .frame(width: 400)
        }
    }

    return Preview()
}
