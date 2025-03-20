//
//  Untitled.swift
//  Discover
//
//  Created by Raudel Armenta on 3/20/25.
//

import SwiftUI

struct VoiceRecognitionView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text(speechRecognizer.recognizedText)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .border(Color.gray, width: 1)
                .frame(height: 400)
            
            if speechRecognizer.isRecording {
                HStack(spacing: 20) {
                    Button(action: {
                        speechRecognizer.cancelTranscription()
                    }) {
                        Text("Cancel")
                    }
                    
                    Button(action: {
                        speechRecognizer.finishTranscription()
                    }) {
                        Text("Finish")
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
