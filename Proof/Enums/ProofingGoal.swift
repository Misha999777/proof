//
//  ProofingGoal.swift
//  Proof
//
//  Created by Михайло Грошевий on 28/11/2025.
//

enum ProofingGoal: String, CaseIterable, Identifiable {
    case fixGrammar = "Fix Grammar & Spelling"
    case professional = "Make Professional"
    case friendly = "Make Friendly & Casual"
    case concise = "Make Concise"
    case summarize = "Summarize"

    var id: String { self.rawValue }

    var promptText: String {
        switch self {
        case .fixGrammar:
            return "Proofread the following text. Fix grammar and spelling errors. Reply with only the corrected plain-text version:"
        case .professional:
            return "Rewrite the following text to sound more professional and formal. Reply with only the rewritten plain-text version:"
        case .friendly:
            return "Rewrite the following text to be more friendly, approachable, and casual. Reply with only the rewritten plain-text version:"
        case .concise:
            return "Rewrite the following text to be more concise and to the point. Remove unnecessary fluff. Reply with only the rewritten plain-text version:"
        case .summarize:
            return "Provide a short summary of the following text:"
        }
    }
}
