//
//  DiscoverTests.swift
//  DiscoverTests
//
//  Created by Trang Do on 4/17/25.
//

import XCTest
@testable import Discover

// OpenAITests tests the OpenAI connection
final class OpenAITests: XCTestCase {
    
    func testOpenAIAPIKey() {
        var openAIKey: String?
        if let key = ProcessInfo.processInfo.environment["OpenAI_API_Key"] {
            openAIKey = key
        }
        XCTAssertNotNil(openAIKey, "There should be an API Key in the Scheme")
        
    }
    
    // Need to make sure OpenAI API is in the Scheme before running this test
    func testOpenAIConnection() {
        let mockOpenAI = OpenAIService()
        let expectation = self.expectation(description: "Mock OpenAI Response")
        var response = ""
        mockOpenAI.sendMessage("What is the capital city of France?") { reply in
            response = reply
            print(response)
            XCTAssertTrue(response.contains("Paris"), "Response should contain the word 'Paris'")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
}

// WebSocketTests tests the WebSocket connection of the app
final class WebsocketTests: XCTestCase {
    
    // Need to make sure EC2 is running before running this test
    func testWebSocketConnection() {
        let mockWebSocket = Websocket()
        let expectation = self.expectation(description: "Mock WebSocket Response")
        
        // Wait for the response is back
        mockWebSocket.onImageResult = { result in
            if !result.isEmpty {
                XCTAssertFalse(mockWebSocket.imageResult.isEmpty, "Image Result should not be empty")
                expectation.fulfill()
            }
        }
        let mockImage = UIImage(systemName: "plus.circle")
        mockWebSocket.sendImageData(mockImage!)
        
        wait(for: [expectation], timeout: 10)
    }
    
}

