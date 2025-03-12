//
//  ResultTableView.swift
//  Discover
//
//  Created by Trang Do on 2/24/25.
//
import Foundation
import SwiftUI

struct ResultTableView: View {
    var imageResults: [ImageResult]
    
    var body: some View {
        Table(imageResults) {
            TableColumn("Detected Objects") { result in
                Text(result.image_label.capitalized)
            }
                .width(500.0)
            TableColumn("Score") { result in
                Text((result.image_score * 100).toString() + "%")
            }
            .width(150.0)
        }
        .frame(width: 650.0, height: 400.0)
    }
}

struct ResultTableView_Previews: PreviewProvider {
    static var previews: some View {
        let images = [ImageResult(image_label: "king penguin, Aptenodytes patagonica", image_score: 0.9929835796356201), ImageResult(image_label: "rock beauty, Holocanthus tricolor", image_score: 0.000786),ImageResult(image_label: "ice bear, polar bear, Ursus Maritimus, Thalarctos maritimus", image_score: 0.000168),ImageResult(image_label: "white wolf, Arctic wolf, Canis lupus tundrarum", image_score: 0.0000621),ImageResult(image_label: "Eskimo dog, husky", image_score: 0.000000721),]
        ResultTableView(imageResults: images )
    }
}
