//
//  ProofreadingService.swift
//  Proof
//
//  Created by Михайло Грошевий on 25/11/2025.
//

import Foundation

func proofread(text: String,
               apiUrl: String? = nil,
               apiKey: String? = nil,
               model: String? = nil,
               completion: @escaping (Bool, String) -> Void) {

    let config = ConfigurationService.shared
    let resolvedApiUrl = apiUrl ?? config.apiUrl
    let resolvedApiKey = apiKey ?? config.apiKey
    let resolvedModel = model ?? config.model

    let isConfigured = !resolvedApiUrl.isEmpty && !resolvedApiKey.isEmpty && !resolvedModel.isEmpty
    guard isConfigured else {
        complete(completion, success: false)
        return
    }

    var urlString = resolvedApiUrl
    if !urlString.hasSuffix("/chat/completions") {
        if !urlString.hasSuffix("/") {
            urlString += "/"
        }
        urlString += "chat/completions"
    }

    guard let endpointURL = URL(string: urlString) else {
        complete(completion, success: false)
        return
    }

    var request = URLRequest(url: endpointURL)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(resolvedApiKey)", forHTTPHeaderField: "Authorization")

    let body: [String: Any] = [
        "model": resolvedModel,
        "messages": [
            [
                "role": "user",
                "content": text
            ]
        ]
    ]
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
    } catch {
        complete(completion, success: false)
        return
    }

    let task = URLSession.shared.dataTask(with: request) { data, response, urlError in
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
            complete(completion, success: false)
            return
        }

        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {

                complete(completion, success: false)
                return
            }
            
            complete(completion, success: true, result: content)
            return

        } catch {
            complete(completion, success: false)
            return
        }
    }
    
    task.resume()
}

func complete(_ completion: @escaping (Bool, String) -> Void, success: Bool, result: String = "") {
    if (success) {
        completion(true, result)
    } else {
        completion(false, String(localized: "API Error"))
    }
}
