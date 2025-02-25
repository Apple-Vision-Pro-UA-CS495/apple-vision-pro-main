//
//  SplashView.swift
//  Discover
//
//  Created by Trang Do on 2/14/25.
//

import SwiftUI

struct SplashView: View {
    
    @State var isOnSplashView: Bool = false
    
    var body: some View {
        ZStack {
            if self.isOnSplashView {
                ContentView()
            } else {
                LottieView(animationFileName: "SplashScreen", loopMode: .loop)
                    .frame(width: 400, height: 400)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    self.isOnSplashView = true
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
            .environment(AppModel())
    }
}

