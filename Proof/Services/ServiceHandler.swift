//
//  ServiceHandler.swift
//  Proof
//
//  Created by Михайло Грошевий on 25/11/2025.
//

import AppKit
import SwiftUI

class ServiceHandler: NSObject {

    @objc func replaceTextWithAPIResult(_ pasteboard: NSPasteboard, userData: String?, error: NSErrorPointer) {
        if SwiftUIPopover.isOpened {
            return
        }
        
        if !ConfigurationService.shared.isConfigured {
            DispatchQueue.main.async {
                let view = ProofView(originalText: "")
                ProofAppDelegate.shared?.showPopover(view: view, recreate: true)
            }
            return
        }

        guard let originalText = pasteboard.string(forType: .string) else { return }
        let prompt = ProofingGoal.fixGrammar.promptText + "\n\n" + originalText
        
        var processedResult: String?
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        proofread(text: prompt, completion: { status, text in
            processedResult = text
            dispatchGroup.leave()
        })
        
        let waitResult = waitForDg(dispatchGroup, timeout: .now() + 10.0)
        if waitResult == .timedOut {
            print("API call timed out.")
            processedResult = "API Timeout"
        }

        if let result = processedResult {
            pasteboard.clearContents()
            pasteboard.setString(result, forType: .string)
        }
    }
    
    @objc func replaceTextWithWindow(_ pasteboard: NSPasteboard, userData: String?, error: NSErrorPointer) {
        if SwiftUIPopover.isOpened {
            return
        }
        
        guard let originalText = pasteboard.string(forType: .string) else {
            return
        }
        
        DispatchQueue.main.async {
            let view = ProofView(originalText: originalText)
            ProofAppDelegate.shared?.showPopover(view: view, recreate: true)
        }
    }
    
    private func waitForDg(_ dg: DispatchGroup, timeout: DispatchTime) -> DispatchTimeoutResult {
        ProofAppDelegate.shared?.changeActivityIndicator(loading: true)
        let waitResult = dg.wait(timeout: timeout)
        ProofAppDelegate.shared?.changeActivityIndicator(loading: false)
        
        return waitResult
    }
}
