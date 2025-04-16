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
    @State private var showResponse = false
    
    var body: some View {
        HStack {
            VStack(spacing: 30) {
                showRecognizedText
                if speechRecognizer.isRecording {
                    HStack(spacing: 20) {
                        resetButton
                        sendRequestButton
                    }
                } else {
                    startRecordingButton
                }
            }
            .padding()
            if showResponse {
                showResponseView
            }
        }
    }
    
    private var showRecognizedText: some View {
        Text(speechRecognizer.recognizedText)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var resetButton: some View {
        Button(action: {
            speechRecognizer.cancelTranscription()
        }) {
            Text("Reset")
            .frame(width: 125)
        }
    }
    
    private var sendRequestButton: some View {
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
            showResponse = true
            
        }) {
            Text("Send Request")
            .frame(width: 125)
        }
    }
    
    private var startRecordingButton: some View {
        Button(action: {
            speechRecognizer.startTranscription()
        }) {
            Text("Start Recording")
                .frame(width: 125)
        }
    }
    
    private var showResponseView: some View {
        ScrollView{
            VStack {
                Text(openAIResponse.isEmpty ? "Processing Request..." : openAIResponse)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
        .defaultScrollAnchor(.center, for: .alignment)
    }
}

#Preview(windowStyle: .automatic) {
    VoiceRecognitionView()
}
