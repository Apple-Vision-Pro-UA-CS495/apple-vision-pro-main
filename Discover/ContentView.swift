//
//  ContentView.swift
//  Discover
//
//  Created by Trang Do on 1/26/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isPickerPresented = false
    @State private var selectedImage: UIImage?
    @ObservedObject var websocket = Websocket()
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
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
                        websocket.sendImageData(image)
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
