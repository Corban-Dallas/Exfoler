//
//  AssetEditor.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 19.11.2021.
//

import SwiftUI

struct AssetEditor: View {
    public var asset: Asset
    @Binding var showEditor: Bool
    
    var body: some View {
        VStack {
            Text(asset.ticker.symbol)
                .font(.headline)
            Button("Close") {
                showEditor = false
            }
        }
        .padding()
    }
}

//struct AssetEditor_Previews: PreviewProvider {
//    static var previews: some View {
//
//        AssetEditor()
//    }
//}
