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
    var originalText: String = ""
    var proofreadText: String = ""
    var selectedGoal: ProofingGoal = .fixGrammar
    var isLoading = false
    
    func reset() {
        originalText = ""
        proofreadText = ""
    }
    
    func runProofreading() {
        guard !originalText.isEmpty && ConfigurationService.shared.isConfigured else { return }
        
        isLoading = true
        let fullPrompt = selectedGoal.promptText + "\n\n" + originalText
        
        proofread(text: fullPrompt) { [weak self] status, text in
            self!.proofreadText = text
            self!.isLoading = false
        }
    }
}

// MARK: - View
struct ProofreadingView: View {
    
    @Binding var showSettings: Bool
    
    @State var vm = ProofreadingModel()
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
                Picker(String(""), selection: $vm.selectedGoal) {
                    ForEach(ProofingGoal.allCases) { goal in
                        Text(goal.title).tag(goal)
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
                styledEditor($vm.originalText, height: 150)
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
                styledEditor(.constant(vm.proofreadText), height: 150)
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
func sectionHeader(_ title: LocalizedStringKey) -> some View {
    Text(title)
        .font(.headline)
        .foregroundStyle(.secondary)
}

@ViewBuilder
func styledEditor(_ text: Binding<String>, height: CGFloat) -> some View {
    TextEditor(text: text)
        .font(.system(size: 14))
        .frame(height: height)
        .padding(4)
        .background(Color(nsColor: .textBackgroundColor))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
}

// MARK: - Preview
#Preview {
    struct Preview: View {
        @State var show = false

        var body: some View {
            ProofreadingView(showSettings: $show)
                .frame(width: 400)
        }
    }

    return Preview()
}
