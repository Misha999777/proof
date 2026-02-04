//
//  ProofingGoal.swift
//  Proof
//
//  Created by Михайло Грошевий on 02/02/2026.
//

import Foundation

enum ProofingGoal: String, CaseIterable, Identifiable {
    case fixGrammar
    case professional
    case friendly
    case concise
    case summarize
    
    var id: Self { self }

    var promptText: String {
        switch self {
        case .fixGrammar:
            return "Proofread the following text. Fix grammar and spelling errors. Reply with only the corrected plain-text version:"
        case .professional:
            return "Rewrite the following text to sound more professional and formal. Reply with only the rewritten plain-text version:"
        case .friendly:
            return "Rewrite the following text to be more friendly, approachable, and casual. Reply with only the rewritten plain-text version:"
        case .concise:
            return "Rewrite the following text to be more concise and to the point. Reply with only the rewritten plain-text version:"
        case .summarize:
            return "Provide a short summary of the following text:"
        }
    }
    
    var title: String {
        switch self {
        case .fixGrammar:
            return String(localized: "Fix Grammar & Spelling")
        case .professional:
            return String(localized: "Make Professional")
        case .friendly:
            return String(localized: "Make Friendly & Casual")
        case .concise:
            return String(localized: "Make Concise")
        case .summarize:
            return String(localized: "Summarize")
        }
    }
}
