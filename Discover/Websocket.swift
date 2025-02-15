//
//  Websocket.swift
//  Discover
//
//  Created by Trang Do on 2/9/25.
//

import Foundation
import UIKit

class Websocket: ObservableObject {
    @Published var messages = [String]()
    
    private var webSocketTask: URLSessionWebSocketTask?
    
    init() {
        self.connect()
    }
    
    private func connect() {
        guard let url = URL(string: "ws://127.0.0.1:8000/ws") else { return }
        let session = URLSession(configuration: .default)
        let request = URLRequest(url: url)
        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()
        receiveMessage()
        sendPing()
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { result in
            switch result {
            case .failure(let error):
                print("Failed to receive message: \(error)")
                self.reconnectWebSocket() // try to reconnect
            case .success(let message):
                switch message {
                case .string(let text):
                    if let data = text.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("Received JSON: \(json)")
                    } else {
                        print("Received text: \(text)")
                    }
                case .data(let data):
                    // Handle binary data
                    print(data)
                    break
                @unknown default:
                    fatalError()
                    break
                }
                self.receiveMessage()
            }
        }
    }
    
    func reconnectWebSocket() {
        print("Reconnecting WebSocket...")
        webSocketTask?.cancel()
        connect()  // Reconnect WebSocket
    }
    
    func sendMessage(_ message: String) {
        let webSocketMessage = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(webSocketMessage) { error in
            if let error = error {
                print("WebSocket send error: \(error)")
            }
        }
    }
    
    func sendImageData(_ image: UIImage) {
        var encodedImage : String?
        if let imageData = image.jpegData(compressionQuality: 1.0) {  // Convert to Data
            encodedImage = imageData.base64EncodedString()  // Convert Data to Base64 string
        }
        
        if let encodedImage = encodedImage {
            let json: [String: Any] = [
                    "type": "image",
                    "data": encodedImage
            ]
            if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                self.sendMessage(jsonString)
            }
        }
        
    }
    
    func sendPing() {
        webSocketTask?.sendPing { (error) in
            if let error = error {
                print("Sending PING failed: \(error)")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                self.sendPing()
            }
        }
    }
}


