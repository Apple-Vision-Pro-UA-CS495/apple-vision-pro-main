//
//  openAIService.swift
//  V2Speech
//
//  Created by Raudel Armenta on 3/19/25.
//

import Foundation

class OpenAIService: ObservableObject {
    
    // Replace with your actual API key. In production, avoid storing it in plain text.
    private let openAIApiKey: String
        
        init() {
            if let key = ProcessInfo.processInfo.environment["OpenAI_API_Key"] {
                self.openAIApiKey = key
            } else {
                // Fallback or error if the env var isn't set
                self.openAIApiKey = ""
                print("Warning: OPENAI_API_KEY environment variable not set.")
            }
        }


    
    func sendMessage(_ userPrompt: String, completion: @escaping (String) -> Void) {
        // 1) Build the URL
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            completion("Invalid URL.")
            return
        }
        
        // 2) Create the JSON request body
        // Using the Chat Completion API with "gpt-3.5-turbo" or "gpt-4"
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "user", "content": userPrompt]
            ],
            "max_tokens": 200
        ]
        
        // Convert dictionary to JSON data
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion("Failed to serialize request JSON.")
            return
        }
        
        // 3) Create a URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(openAIApiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = httpBody
        
        // 4) Send the request via URLSession
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network or server errors
            if let error = error {
                completion("Network error: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                completion("No data in response.")
                return
            }
            
            // 5) Parse the JSON response
            // Typical OpenAI response format for chat completion:
            // {
            //   "choices": [
            //       {
            //         "message": {
            //           "role": "assistant",
            //           "content": "Hello!"
            //         }
            //       }
            //   ],
            //   ...
            // }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let messageDict = firstChoice["message"] as? [String: Any],
                   let assistantReply = messageDict["content"] as? String {
                    completion(assistantReply.trimmingCharacters(in: .whitespacesAndNewlines))
                } else {
                    // If the response didn’t match the expected format
                    let responseString = String(data: data, encoding: .utf8) ?? ""
                    completion("Unexpected response: \(responseString)")
                }
            } catch {
                completion("JSON parse error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}
