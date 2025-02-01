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

            Button(action: {
                isPickerPresented = true
            }) {
                Text("Pick Photo")
            }
            .sheet(isPresented: $isPickerPresented) {
                PhotoPickerView(selectedImage: $selectedImage)
            }
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
        .environment(AppModel())
}
