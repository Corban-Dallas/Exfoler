//
//  AssetsView.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 30.10.2021.
//

import SwiftUI

struct AssetsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest private var assets: FetchedResults<Asset>
    
    @State var sortOrder: [KeyPathComparator<Asset>] = [
        .init(\.name, order: SortOrder.forward)
    ]
    private var sortedAssets: [Asset] { assets.sorted(using: sortOrder) }
    private var portfolio: Portfolio?
    
    @State var selection = Set<Asset.ID>()

    @State var showAssetEditor = false
        
    var body: some View {
        Table(selection: $selection, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.name)
                .width(ideal: 300.0)
            TableColumn("Ticker", value: \.ticker.symbol)
                .width(min: 40.0, ideal: 40.0)
            TableColumn("Count", value: \.purchaseCount) {
                Text("\($0.purchaseCount)")
            }
            .width(ideal: 15.0)
            TableColumn("Buy price", value: \.purchasePrice) {
                Text("\($0.purchasePrice)")
            }
            .width(min: 40.0, ideal: 40.0)

            TableColumn("Price", value: \.ticker.price) {
                Text("\($0.ticker.price)")
            }
            .width(min: 40.0, ideal: 40.0)
        } rows: {
            ForEach(sortedAssets) { asset in
                TableRow(asset)
                    .itemProvider { asset.itemProvider }
            }
            .onInsert(of: [Asset.draggableType]) { _, providers in
                Asset.fromItemProviders(providers, context: viewContext) { assets in
                    assets.forEach { $0.portfolio = self.portfolio }
                }
            }
        }
        .sheet(isPresented: $showAssetEditor) {
            AssetEditor(asset: Asset.withID(selection.first!, in: viewContext), showEditor: $showAssetEditor)
        }
        .contextMenu {
            if selection.count == 1 {
                Button("Edit") {
                    showAssetEditor = true
                }
            }
            if selection.count > 0 {
                Button("Delete") {
                    showDeleteAlert = true
                }
            }
        }
        .alert(isPresented: $showDeleteAlert, content: {deleteAlert})
    }
    
    init(portfolio: Portfolio? = nil) {
        let request = NSFetchRequest<Asset>(entityName: "Asset")
        if let portfolio = portfolio {
            self.portfolio = portfolio
            request.predicate = NSPredicate(format: "portfolio.id_ = %@", portfolio.id as CVarArg)
        }
        request.sortDescriptors = []
        _assets = FetchRequest(fetchRequest: request, animation: .default)
    }

    
    @State private var showDeleteAlert = false
    private var deleteAlert: Alert {
        let title = Text("Delete assets")
        let message = Text("Are you sure that you want delete \(selection.count) assets?")
        return Alert(title: title,
              message: message,
              primaryButton: .destructive(Text("Delete"), action: deleteSelection),
              secondaryButton: .cancel())
    }

    // MARK: - User intents
    private func deleteSelection() {
        selection.forEach { id in
            let asset = assets.first(where: { $0.id == id })!
            viewContext.delete(asset)
        }
        self.selection.removeAll()
        // We need wait some time before save changes in context
        // or UI will not animate deletion because of late updating
        // assets: FetchResaults. There must be better solution?
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            try? viewContext.save()
        }
    }
}

struct AssetsTable_Previews: PreviewProvider {
    static var previews: some View {
        AssetsView()
    }
}
