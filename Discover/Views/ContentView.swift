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
        HStack(alignment: .center){
            VStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400, height: 400)
                        .clipShape(.rect(cornerRadius: 10))
                        .shadow(radius: 10)
                    
                } else {
                    Text("Pick a photo to get started!")
                        .font(.largeTitle)
                    LottieView(animationFileName: "Discover", loopMode: .loop)
                        .frame(width: 400, height: 400)
                }
                HStack {
                    Button(action: {
                        isPickerPresented = true
                        websocket.clearImageResult()
                    }) {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                        Text("Select photo")
                    }
                    .sheet(isPresented: $isPickerPresented) {
                        PhotoPickerView(selectedImage: $selectedImage)
                    }
                    if let image = selectedImage {
                        Button(action: {
                            websocket.sendImageData(image)
                        }) {
                            Image(systemName: "paperplane")
                            Text("Submit")
                        }
                    }
                }
            }
            if !websocket.imageResult.isEmpty {
                VStack {
                    Spacer()
                    Text("Result").font(.largeTitle)
                    ResultTableView(imageResults: $websocket.imageResult)
                    Spacer()
                }
                
            }
            
        }
        
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
        .environment(AppModel())
}
