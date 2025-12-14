//
//  ProofApp.swift
//  Proof
//
//  Created by Михайло Грошевий on 25/11/2025.
//

import AppKit
import SwiftUI

@main
struct ProofApp: App {
    
    @NSApplicationDelegateAdaptor(ProofAppDelegate.self) var appDelegate
    
    var body: some Scene {
        Window("Main Window", id: "main-window") {
            EmptyView()
        }
        .defaultLaunchBehavior(.suppressed)
    }
}
