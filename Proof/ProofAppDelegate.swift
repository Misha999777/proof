//
//  ProofAppDelegate.swift
//  Proof
//
//  Created by Михайло Грошевий on 25/11/2025.
//

import AppKit
import SwiftUI
import ServiceManagement

class ProofAppDelegate: NSObject, NSApplicationDelegate {
    
    static var shared: ProofAppDelegate?
    
    private var serviceHandler: ServiceHandler!
    private var statusItem: NSStatusItem!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        ProofAppDelegate.shared = self
        
        registerServiceHandler()
        createStatusBar()
        enableAutoStart()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func changeActivityIndicator(loading: Bool) {
        let image = loading
            ? NSImage(systemSymbolName: "hourglass", accessibilityDescription: "Processing...")
            : NSImage(systemSymbolName: "doc.text", accessibilityDescription: "Proof App")
        
        DispatchQueue.main.async { [self] in
            statusItem.button?.image = image
        }
        
        if (loading) {
            CFRunLoopRunInMode(.defaultMode, 0.1, false)
        }
    }
    
    func showPopover(view: some View, recreate: Bool) {
        SwiftUIPopover.open(view: view, button: statusItem.button!, recreate: recreate)
    }
    
    private func registerServiceHandler() {
        serviceHandler = ServiceHandler()
        NSApp.servicesProvider = serviceHandler
        print("macOS Service initialized and registered.")
    }
    
    private func createStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.text", accessibilityDescription: "Proof App")
            button.action = #selector(showPopover)
        }
        
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { _ in
            SwiftUIPopover.reposition()
        }
        
        print("StatusBar item created.")
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

    @objc private func showPopover() {
        DispatchQueue.main.async {
            let view = ProofView(originalText: "")
            self.showPopover(view: view, recreate: false)
        }
    }
}
