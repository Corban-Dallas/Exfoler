//
//  SearchResultsView.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 20.10.2021.
//

import SwiftUI

struct SearchResultsView: View {
    @Binding var assets: [Asset]?
    var body: some View {
        if let assets = assets {
            List(assets) { asset in
                Text(asset.name ?? "N/A")
            }
        } else {
            ProgressView()
        }
    }
}

//struct SearchResultsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchResultsView()
//    }
//}
