//
//  ProofApp.swift
//  Proof
//
//  Created by Михайло Грошевий on 25/11/2025.
//

import SwiftUI

@Observable
class ProofModel {
    var isLoading = false
    var showSettings = false
    private var isConfigured = ConfigurationService.shared.isConfigured
    
    var shouldShowSettings: Bool {
        return showSettings || !isConfigured
    }
    
    func settingsClosed() {
        showSettings = false
        isConfigured = ConfigurationService.shared.isConfigured
    }
    
    func updateStatus(status: Bool) {
        isLoading = status
    }
}

@main
struct ProofApp: App {
    
    @NSApplicationDelegateAdaptor(ProofAppDelegate.self) var appDelegate
    @State var proofModel = ProofModel()
    
    init() {
        appDelegate.processingCallback = proofModel.updateStatus
    }
    
    var body: some Scene {
        MenuBarExtra(String("Proof"), systemImage: proofModel.isLoading ? "hourglass" : "doc.text") {
            Group {
                if proofModel.shouldShowSettings {
                    SettingsView(onClose: proofModel.settingsClosed)
                } else {
                    ProofreadingView(showSettings: $proofModel.showSettings)
                }
            }
            .frame(width: 400)
        }
        .menuBarExtraStyle(.window)
    }
}
