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
        completion(false, "Error: Configuration missing. Please configure API URL, Key, and Model.")
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
        completion(false, "Error: Invalid API URL.")
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
        completion(false, "Error serializing JSON: \(error)")
        return
    }

    let task = URLSession.shared.dataTask(with: request) { data, response, urlError in
        if let urlError = urlError {
            completion(false, "Network error: \(urlError.localizedDescription)")
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            completion(false, "API Error: Invalid HTTP response.")
            return
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorBody = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
            completion(false, "API Error: Status \(httpResponse.statusCode). Body: \(errorBody)")
            return
        }

        guard let data = data else {
            completion(false, "API Error: Empty response.")
            return
        }

        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {

                completion(false, "Could not parse response data: \(String(data: data, encoding: .utf8) ?? "N/A")")
                return
            }
            
            completion(true, content)
            return

        } catch {
            completion(false, "JSON parsing error: \(error)")
            return
        }
    }
    
    task.resume()
}
