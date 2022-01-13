//
//  TickersView.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 29.11.2021.
//

import SwiftUI
import CoreData

struct TickersView: View {
    @Environment(\.managedObjectContext) private var viewContext

    
    @FetchRequest(sortDescriptors: []) public var tickers: FetchedResults<Ticker>
    @State var selection: Set<Ticker.ID> = .init()
    @State var sortOrder: [KeyPathComparator<Ticker>] = [
        .init(\.name, order: SortOrder.forward)
    ]
    private var sortedTickers: [Ticker] {
        tickers.sorted(using: sortOrder)
    }

    var body: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.name)
            TableColumn("Ticker", value: \.symbol)
            TableColumn("Price", value: \.price) { Text("\($0.price)") }
            TableColumn("Market", value: \.market)
            TableColumn("Currency", value: \.currency)
        
            TableColumn("Related assets", value: \.price) {
                Text("\($0.relatedAssets!.count)")
            }

        } rows: {
            ForEach(sortedTickers) { ticker in
                TableRow(ticker)
            }
        }
        .contextMenu {
            if selection.count > 0 {
                Button("Delete", action: deleteSelection)
            }
        }
    }
    
    private func deleteSelection() {
        selection.forEach {
            viewContext.delete(Ticker.withID($0, in: viewContext))
        }
        selection.removeAll()
        try? viewContext.save()
    }
}

struct TickersView_Previews: PreviewProvider {
    static var previews: some View {
        TickersView()
    }
}
