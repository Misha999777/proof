//
//  ProcessedTextView.swift
//  Proof
//
//  Created by Михайло Грошевий on 09/12/2025.
//

import SwiftUI

// MARK: - View
struct ProofView: View {

    @State var proofreadingModel: ProofreadingModel
    
    @State var showSettings = false
    @State var isConfigured = ConfigurationService.shared.isConfigured
    
    init(originalText: String) {
        _proofreadingModel = State(initialValue: ProofreadingModel(originalText: originalText))
    }
    
    var body: some View {
        Group {
            if !isConfigured {
                SettingsView(onClose: {
                    updateConfigStatus()
                })
            } else if showSettings {
                SettingsView(onClose: {
                    showSettings = false
                })
            } else {
                ProofreadingView(vm: proofreadingModel, showSettings: $showSettings)
            }
        }
        .onAppear {
            updateConfigStatus()
        }
    }

    func updateConfigStatus() {
        isConfigured = ConfigurationService.shared.isConfigured
    }
}

// MARK: - Preview
#Preview {
    ProofView(
        originalText: ""
    )
    .frame(width: 400)
}
