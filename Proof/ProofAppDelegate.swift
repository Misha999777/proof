//
//  ProofAppDelegate.swift
//  Proof
//
//  Created by Михайло Грошевий on 25/11/2025.
//

import AppKit
import ServiceManagement

class ProofAppDelegate: NSObject, NSApplicationDelegate {
    
    var processingCallback: ((Bool) -> Void)?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        registerServiceHandler()
        enableAutoStart()
    }
    
    private func registerServiceHandler() {
        NSApp.servicesProvider = ServiceHandler() { status in
            guard let callback = self.processingCallback else { return }
            callback(status)
        }
        print("macOS Service initialized and registered.")
    }
    
    private func enableAutoStart() {
        let status = SMAppService.mainApp.status
        
        if (status == .enabled || status == .requiresApproval) {
            print("Autostart already requested.")
            return
        }
        
        do {
            try SMAppService.mainApp.register()
            print("Autostart enabled.")
        } catch {
            print("Failed to enable autostart.")
        }
    }
}
