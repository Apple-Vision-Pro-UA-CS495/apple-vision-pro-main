//
//  Websocket.swift
//  Discover
//
//  Created by Trang Do on 2/9/25.
//

import Foundation


var webSocketTask: URLSessionWebSocketTask?

func connectWebsocket() {
    let urlSession = URLSession(configuration: .default)
    let url = URL(string: "wss://r9y6h6a4d5.execute-api.us-east-1.amazonaws.com/creation/")!
    webSocketTask = urlSession.webSocketTask(with: url)
    webSocketTask?.resume()
}

func sendImageData(_ image: String) {
    let message = URLSessionWebSocketTask.Message.string("{\"image\": \"\(image)\"}")
    webSocketTask?.send(message) { error in
        if let error = error {
            print("WebSocket sending error: \(error)")
        } else {
            print("Image data sent successfully")
        }
    }
}

func receiveData() {
    webSocketTask?.receive { result in
        switch result {
        case .failure(let error):
            print("Failed to receive message: \(error)")
        case .success(let message):
            switch message {
            case .string(let text):
                print("Received text message: \(text)")
            case .data(let data):
                print("Received binary message: \(data)")
            @unknown default:
                fatalError()
            }
        }
    }
}


