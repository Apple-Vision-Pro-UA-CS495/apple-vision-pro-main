//
//  SpeechRecognition.swift
//  Discover
//
//  Created by Raudel Armenta on 3/20/25.
//
import SwiftUI
import Foundation
import AVFoundation
import Speech


class SpeechRecognizer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    @Published var recognizedText: String = "Tap Start Recording to begin"
    @Published var isRecording: Bool = false
    
    private let audioEngine = AVAudioEngine()
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    override init() {
        super.init()
        speechRecognizer?.delegate = self
        
        // Request permission at init
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self?.recognizedText = "Tap Start Recording to begin"
                case .denied:
                    self?.recognizedText = "Speech recognition access denied by user"
                case .restricted, .notDetermined:
                    self?.recognizedText = "Speech recognition not available"
                @unknown default:
                    self?.recognizedText = "Speech recognition not available"
                }
            }
        }
    }
    
    func startTranscription() {
        guard !audioEngine.isRunning else { return }
        
        // Check authorization status
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            recognizedText = "Speech recognition not authorized"
            return
        }
        
        // Check if speechRecognizer is available
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            recognizedText = "Speech recognizer not available"
            return
        }
        
        isRecording = true
        recognizedText = "Listening..."
        
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request = request else {
            recognizedText = "Unable to create speech request"
            return
        }
        
        // Configure for partial results
        request.shouldReportPartialResults = true
        
        // Audio session setup
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            // Prepare audio input
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                request.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            // Start recognition
            recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
                guard let self = self else { return }
                
                if let error = error {
                    // Check if it's a cancellation error
                    let isCancellationError = error._domain == "kAFAssistantErrorDomain" &&
                                            error._code == 209 ||
                                            error.localizedDescription == "Recognition request was cancelled"
                    
                    // Only report error if it's not a cancellation error
                    if !isCancellationError && self.isRecording {
                        DispatchQueue.main.async {
                            self.recognizedText = "Recognition error: \(error.localizedDescription)"
                        }
                    }
                    return
                }
                
                if let result = result {
                    DispatchQueue.main.async {
                        self.recognizedText = result.bestTranscription.formattedString
                    }
                }
            }
        } catch {
            recognizedText = "Audio setup failed: \(error.localizedDescription)"
            stopTranscription(preserveText: false)
        }
    }
    
    func cancelTranscription() {
        stopTranscription(preserveText: false)
        recognizedText = "Recording cancelled"
    }
    
    func finishTranscription() {
        // Get the final text
        request?.endAudio()
        
        // A slight delay to make sure we get the final result
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.stopTranscription(preserveText: true)
        }
    }
    
    func pauseTranscription() {
        guard isRecording else { return }
        
        audioEngine.stop()
        isRecording = false
    }
    
    func resumeTranscription(){
        guard !audioEngine.isRunning else { return }
            do {
                try audioEngine.start()
                isRecording = true
                recognizedText += "\n[Resumed recording]"
            } catch {
                recognizedText = "Error resuming audio: \(error.localizedDescription)"
            }
    }
    
    
    // Modify this method in your SpeechRecognizer class
    private func stopTranscription(preserveText: Bool) {
        isRecording = false
        
        // Capture the current recognized text before stopping
        let currentText = recognizedText
        
        // Only stop audio engine if it's running
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        // End the recognition request
        request?.endAudio()
        
        // Cancel the task if it exists
        recognitionTask?.cancel()
        recognitionTask = nil
        request = nil
        
        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        
        // Preserve the recognized text if requested
        if !preserveText {
            recognizedText = "Recording cancelled" // Only if explicitly cancelling
        } else if currentText == "Listening..." {
            recognizedText = "No speech detected"
        }
        // If preserveText is true and we have text, just keep the current text
    }
}
