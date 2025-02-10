//
//  ContentView.swift
//  Discover
//
//  Created by Trang Do on 1/26/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @State private var isPickerPresented = false
    @State private var selectedImage: UIImage?

    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            }
            HStack {
                Button(action: {
                    isPickerPresented = true
                }) {
                    Text("Pick Photo")
                }
                .sheet(isPresented: $isPickerPresented) {
                    PhotoPickerView(selectedImage: $selectedImage)
                }
                if let image = selectedImage {
                    Button(action: {
                        let imageData = image.pngData()!
                        let encodedImage = imageData.base64EncodedString()
                        connectWebsocket()
                        sendImageData(encodedImage)
                    }) {
                        Text("Submit")
                    }
                }
            }
            
        }
        
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
        .environment(AppModel())
}
