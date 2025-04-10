//
//  MainView.swift
//  Discover
//
//  Created by Trang Do on 1/26/25.
//

import SwiftUI

struct MainView: View {
    @State private var isPickerPresented = false
    @State private var isVoicePresented = false
    @State private var selectedImage: UIImage?
    @StateObject var websocket = Websocket()
    
    
    var body: some View {
        HStack(alignment: .center){
            VStack {
                if let image = selectedImage {
                    displayImage(image)
                } else if !isVoicePresented {
                    displayAnimation
                }
                HStack {
                    selectPhotoButton
                    .sheet(isPresented: $isPickerPresented) {
                        PhotoPickerView(selectedImage: $selectedImage)
                    }
                    if let image = selectedImage {
                        submitPhotoButton(image)
                    }
                    voiceRecognition
                        .sheet(isPresented: $isVoicePresented) {
                            VStack {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        isVoicePresented = false
                                    }) {
                                        Text("Cancel")
                                    }
                                }
                                .padding()
                                VoiceRecognitionView()
                            }
                            
                        }
                }
            }
            if !websocket.imageResult.isEmpty {
                displayResult
            }
        }
    }
    
    private func displayImage(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: 400, height: 400)
            .clipShape(.rect(cornerRadius: 10))
            .shadow(radius: 10)
    }
    
    @ViewBuilder
    private var displayAnimation: some View {
        Text("Pick a photo to get started!")
            .font(.largeTitle)
        LottieView(animationFileName: "Discover", loopMode: .loop)
            .frame(width: 400, height: 400)
    }
    
    private var selectPhotoButton: some View {
        Button(action: {
            isPickerPresented = true
            websocket.clearImageResult()
        }) {
            Image(systemName: "photo")
                .font(.largeTitle)
            Text("Select photo")
        }
    }
    
    private func submitPhotoButton(_ image: UIImage) -> some View {
        Button(action: {
            websocket.sendImageData(image)
        }) {
            Image(systemName: "paperplane")
            Text("Submit Image")
        }
    }
    
    private var voiceRecognition: some View {
        Button(action: {
            isVoicePresented = true
        }) {
            Image(systemName: "microphone")
            Text("Speak Now")
        }
    }
    
    private var displayResult: some View {
        VStack {
            Spacer()
            Text("Result").font(.largeTitle)
            ResultTableView(imageResults: websocket.imageResult)
            Spacer()
        }
    }
}

#Preview(windowStyle: .volumetric) {
    MainView()
        .environment(AppModel())
}
