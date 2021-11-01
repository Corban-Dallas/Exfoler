//
//  AssetsView.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 30.10.2021.
//

import SwiftUI

struct AssetsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest var assets: FetchedResults<Asset>
    @State var sortOrder: [KeyPathComparator<Asset>] = [
        .init(\.name, order: SortOrder.forward)
    ]
    var sortedAssets: [Asset] {
        assets.sorted(using: sortOrder)
    }
    
    private var portfolio: Portfolio?
    
    @State var selection = Set<Asset.ID>()

    init(portfolio: Portfolio? = nil) {
        let request = NSFetchRequest<Asset>(entityName: "Asset")
        if let portfolio = portfolio {
            self.portfolio = portfolio
            request.predicate = NSPredicate(format: "portfolio.id_ = %@", portfolio.id as CVarArg)
        }
        request.sortDescriptors = []
        _assets = FetchRequest(fetchRequest: request, animation: .default)
    }
        
    var body: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.name)
            TableColumn("Ticker", value: \.ticker)
            TableColumn("Price", value: \.currentPrice) { Text("\($0.currentPrice)") }
        } rows: {
            ForEach(sortedAssets) { asset in
                TableRow(asset).itemProvider { asset.itemProvider }
            }
            .onInsert(of: [Asset.draggableType]) { _, providers in
                Asset.fromItemProviders(providers) { assets in
                    assets.forEach { $0.portfolio = self.portfolio }
                }
            }

        }
        .contextMenu {
            Button {
                
            } label: {
                Text("Delete")
            }
        }
    }
}

struct AssetsTable_Previews: PreviewProvider {
    static var previews: some View {
        AssetsView()
    }
}
