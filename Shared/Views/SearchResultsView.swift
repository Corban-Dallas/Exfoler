//
//  SearchResultsView.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 20.10.2021.
//

import SwiftUI

struct SearchResultsView: View {
    @EnvironmentObject var dataFetcher: SearchEngine
    @Environment(\.managedObjectContext) private var viewContext

    private var assets: [AssetInfo] {
        dataFetcher.searchResults
            .sorted(using: sortOrder)
    }
    
    @State var selection = Set<AssetInfo.ID>()
    @State var sortOrder: [KeyPathComparator<AssetInfo>] = [
        .init(\.name, order: SortOrder.forward)
    ]
    
    var body: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.name)
            TableColumn("Ticker", value: \.ticker)
            TableColumn("Type", value: \.type)
            TableColumn("Locale", value: \.locale)
            TableColumn("Currency", value: \.currency)
        } rows: {
            ForEach(assets) { asset in
                TableRow(asset).itemProvider { asset.itemProvider }
            }
        }
        .toolbar {
            if dataFetcher.isSearching {
                ProgressView()
            }
            Button {
                try? viewContext.save()
            } label: {
                Text("Save")
            }
        }
    }
}

//struct SearchResultsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchResultsView()
//    }
//}
