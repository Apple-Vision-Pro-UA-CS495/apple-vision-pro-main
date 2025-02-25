//
//  Extensions.swift
//  Discover
//
//  Created by Trang Do on 2/1/25.
//
/*
Abstract:
An extension to convert a `CVPixelBuffer` to a SwiftUI `Image`.
*/

import SwiftUI

extension CVPixelBuffer {
    var image: Image? {
        let ciImage = CIImage(cvPixelBuffer: self)
        let context = CIContext(options: nil)
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }

        let uiImage = UIImage(cgImage: cgImage)

        return Image(uiImage: uiImage)
    }
}

extension Double {
    func toString() -> String {
        return String(format: "%.3f",self)
    }
}
