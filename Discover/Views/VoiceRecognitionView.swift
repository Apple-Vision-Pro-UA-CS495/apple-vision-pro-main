//
//  Untitled.swift
//  Discover
//
//  Created by Raudel Armenta on 3/20/25.
//

import SwiftUI

struct VoiceRecognitionView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @StateObject private var openAIService = OpenAIService()

    // We'll store the OpenAI response here
    @State private var openAIResponse: String = ""

    var body: some View {
        VStack(spacing: 20) {
            
            // 1) Show the recognized speech
            Text(speechRecognizer.recognizedText)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .border(Color.gray, width: 1)
                .frame(height: 250)
            
            // 2) Show the OpenAI response
            Text(openAIResponse.isEmpty ? "No response yet." : openAIResponse)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .border(Color.gray, width: 1)
                .frame(height: 100)
            
            // 3) Buttons
            if speechRecognizer.isRecording {
                HStack(spacing: 20) {
                    
                    Button(action: {
                        speechRecognizer.cancelTranscription()
                    }) {
                        Text("Pause Recording")
                    }
                    
                    Button(action: {
                        // A) Stop the speech session
                        speechRecognizer.finishTranscription()
                        
                        // B) Grab the final recognized text
                        let userPrompt = speechRecognizer.recognizedText
                        
                        // C) Send to OpenAI
                        openAIService.sendMessage(userPrompt) { reply in
                            // Update UI on main thread
                            DispatchQueue.main.async {
                                openAIResponse = reply
                            }
                        }
                    }) {
                        Text("Send Request")
                    }
                }
            } else {
                Button(action: {
                    speechRecognizer.startTranscription()
                }) {
                    Text("Start Recording")
                }
            }
        }
        .padding()
    }
}
