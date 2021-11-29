//
//  AssetEditor.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 19.11.2021.
//

import SwiftUI

struct AssetEditor: View {
    public var asset: Asset
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var showEditor: Bool
    
    @State private var purchasePrice = 0.0
    @State private var purchaseCount: Int = 0
    @State private var purchaseDate = Date()
    
    var body: some View {
        VStack {
            Text(asset.ticker.symbol)
                .font(.headline)
            Form {
                TextField("Purchase price", value: $purchasePrice, format: .number)
                TextField("Purchase count", value: $purchaseCount, format: .number)
                DatePicker("Purchase date", selection: $purchaseDate)
            }
            HStack {
                Button("Apply", action: applyChanges)
                Button("Close", action: closeEditor)
            }
        }
        .padding()
        .onAppear {
            purchasePrice = asset.purchasePrice
            purchaseCount = Int(asset.purchaseCount)
            purchaseDate = asset.purchaseDate ?? Date()
        }
    }

    private func applyChanges() {
        asset.purchasePrice = purchasePrice > 0 ? Double(purchasePrice) : 0.0
        asset.purchaseCount = purchaseCount > 0 ? Int32(purchaseCount) : 0
        asset.purchaseDate = purchaseDate
        try? viewContext.save()
        showEditor = false
    }

    private func closeEditor() {
        showEditor = false
    }
    
}

//struct AssetEditor_Previews: PreviewProvider {
//    static var previews: some View {
//
//        AssetEditor()
//    }
//}
