//
//  ConfigurationService.swift
//  Proof
//
//  Created by Михайло Грошевий on 09/12/2025.
//

import Foundation

class ConfigurationService {
    static let shared = ConfigurationService()

    private let defaults = UserDefaults.standard

    private let keyApiUrl = "proof_api_url"
    private let keyApiKey = "proof_api_key"
    private let keyModel = "proof_model"

    var apiUrl: String {
        didSet { defaults.set(apiUrl, forKey: keyApiUrl) }
    }

    var apiKey: String {
        didSet { defaults.set(apiKey, forKey: keyApiKey) }
    }

    var model: String {
        didSet { defaults.set(model, forKey: keyModel) }
    }

    private init() {
        self.apiUrl = defaults.string(forKey: keyApiUrl) ?? ""
        self.apiKey = defaults.string(forKey: keyApiKey) ?? ""
        self.model = defaults.string(forKey: keyModel) ?? ""
    }

    var isConfigured: Bool {
        return !apiKey.isEmpty && !apiUrl.isEmpty && !model.isEmpty
    }
}
