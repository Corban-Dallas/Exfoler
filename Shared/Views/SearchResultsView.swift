//
//  SearchResultsView.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 20.10.2021.
//

import SwiftUI

struct SearchResultsView: View {
    @EnvironmentObject var dataFetcher: DataFetcher
    private var assets: [Asset] {
        dataFetcher.searchResults
            .sorted(using: sortOrder)
    }
    
    @State var selection = Set<Asset.ID>()
    @State var sortOrder: [KeyPathComparator<Asset>] = [
        .init(\.name, order: SortOrder.forward)
    ]

    
    var body: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.name)
            TableColumn("Ticker", value: \.ticker)
            TableColumn("Price", value: \.currentPrice) { asset in
                Text(asset.currentPrice.formatted())
            }
        } rows: {
            ForEach(assets) { asset in
                TableRow(asset)
            }
        }
        .toolbar {
            if dataFetcher.isSearching {
                ProgressView()
            }
        }
    }
}

private struct BoolComparator: SortComparator {
    typealias Compared = Bool

    func compare(_ lhs: Bool, _ rhs: Bool) -> ComparisonResult {
        switch (lhs, rhs) {
        case (true, false):
            return order == .forward ? .orderedDescending : .orderedAscending
        case (false, true):
            return order == .forward ? .orderedAscending : .orderedDescending
        default: return .orderedSame
        }
    }

    var order: SortOrder = .forward
}


//struct SearchResultsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchResultsView()
//    }
//}
