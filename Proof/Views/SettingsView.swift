//
//  SettingsView.swift
//  Proof
//
//  Created by Михайло Грошевий on 09/12/2025.
//

import SwiftUI

// MARK: - ViewModel
@Observable
class SettingsViewModel {
    
    enum TestResult {
        case success
        case failure
        case progress
        case unknown
    }
    
    var apiUrl: String
    var apiKey: String
    var model: String

    var testStatus = TestResult.unknown

    init() {
        let config = ConfigurationService.shared
        self.apiUrl = config.apiUrl
        self.apiKey = config.apiKey
        self.model = config.model
    }
    
    func save() {
        ConfigurationService.shared.apiUrl = apiUrl
        ConfigurationService.shared.apiKey = apiKey
        ConfigurationService.shared.model = model
    }

    func testConnection() {
        testStatus = .progress

        proofread(text: "Hello", apiUrl: apiUrl, apiKey: apiKey, model: model) { [weak self] success, response in
            DispatchQueue.main.async {
                if success {
                    self!.testStatus = .success
                } else {
                    self!.testStatus = .failure
                }
            }
        }
    }
}

// MARK: - View
struct SettingsView: View {
    
    var onClose: () -> Void = {}
    
    @State var vm = SettingsViewModel()
    @FocusState var focused
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Configuration", systemImage: "gearshape.fill")
                    .font(.headline)
                
                Text("Proof works with any Model Provider that supports an OpenAI-compatible API (e.g., OpenAI, Gemini, Ollama).")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
                GridRow {
                    Text("API URL")
                        .gridColumnAlignment(.trailing)
                    TextField(String("https://generativelanguage.googleapis.com/v1beta/openai/"), text: $vm.apiUrl)
                        .textFieldStyle(.roundedBorder)
                        .focused($focused)
                        .onAppear {
                            DispatchQueue.main.async {
                                focused = true
                            }
                        }
                }
                
                GridRow {
                    Text("API Key")
                        .gridColumnAlignment(.trailing)
                    SecureField(String("********"), text: $vm.apiKey)
                        .textFieldStyle(.roundedBorder)
                }
                
                GridRow {
                    Text("Model")
                        .gridColumnAlignment(.trailing)
                    TextField(String("gemini-2.5-flash"), text: $vm.model)
                        .textFieldStyle(.roundedBorder)
                }
            }
            
            HStack {
                Button {
                    vm.testConnection()
                } label: {
                    if vm.testStatus == .progress {
                        ProgressView().controlSize(.small)
                    } else {
                        Text("Test Connection")
                    }
                }
                .disabled(vm.testStatus == .progress || vm.apiUrl.isEmpty || vm.apiKey.isEmpty || vm.model.isEmpty)
                
                if vm.testStatus == .success || vm.testStatus == .failure  {
                    Text(vm.testStatus == .success ? "Connection Successfull" : "Connection Failed")
                        .font(.caption)
                        .foregroundStyle(vm.testStatus == .success ? .green : .red)
                }
            }
            
            Divider()
            
            HStack {
                Button(role: .destructive) {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Label("Exit", systemImage: "power")
                }
                
                Spacer()
                
                if ConfigurationService.shared.isConfigured {
                    Button("Cancel") {
                        onClose()
                    }
                    .keyboardShortcut(.cancelAction)
                }
                
                Button {
                    vm.save()
                    onClose()
                } label: {
                    Text("Save & Close")
                        .frame(minWidth: 80)
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.testStatus != .success)
            }
        }
        .padding(20)
    }
}

// MARK: - Preview
#Preview {
    SettingsView(onClose: {})
        .frame(width: 400)
}
