//
//  ImageResult.swift
//  Discover
//
//  Created by Trang Do on 2/24/25.
//

import Foundation

struct ImageResult: Identifiable {
    let id = UUID()
    let image_label: String
    let image_score: Double
}
