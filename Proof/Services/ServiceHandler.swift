//
//  ServiceHandler.swift
//  Proof
//
//  Created by Михайло Грошевий on 25/11/2025.
//

import AppKit

class ServiceHandler: NSObject {
    
    var processingStatusCnaged: (Bool) -> Void
    
    init(processingStatusCnaged: @escaping (Bool) -> Void) {
        self.processingStatusCnaged = processingStatusCnaged
    }

    @objc func replaceTextWithAPIResult(_ pasteboard: NSPasteboard, userData: String?, error: NSErrorPointer) {
        if NSApp.isActive {
            return
        }
        
        if !ConfigurationService.shared.isConfigured {
            pasteboard.clearContents()
            pasteboard.setString(String(localized: "Proof needs to be configured before this service can be used"), forType: .string)
            return
        }
        
        processingStatusCnaged(true)
        CFRunLoopRunInMode(.defaultMode, 0.1, false)

        guard let originalText = pasteboard.string(forType: .string) else { return }
        let prompt = ProofingGoal.fixGrammar.promptText + "\n\n" + originalText
        
        var processedResult: String?
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        proofread(text: prompt, completion: { status, text in
            processedResult = text
            dispatchGroup.leave()
        })
        
        let waitResult = dispatchGroup.wait(timeout: .now() + 10.0)
        if waitResult == .timedOut {
            print("API call timed out.")
            processedResult = String(localized: "API Timeout")
        }

        if let result = processedResult {
            pasteboard.clearContents()
            pasteboard.setString(result, forType: .string)
        }
        
        processingStatusCnaged(false)
    }
}
