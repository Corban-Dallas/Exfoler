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
    
    @State var sortOrder: [KeyPathComparator<Asset>] = [.init(\.name, order: SortOrder.forward)]
    private var sortedAssets: [Asset] { assets.sorted(using: sortOrder) }
    private var portfolio: Portfolio?
    
    @State var selection = Set<Asset.ID>()
    @State var assetToEdit: Asset?
        
    var body: some View {
        VStack {
            summaryView
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
        }
        .sheet(item: $assetToEdit) { asset in
            AssetEditor(asset: asset)
        }
        .contextMenu {
            if selection.count == 1 {
                Button("Edit") {
                    assetToEdit = Asset.withID(selection.first!, in: viewContext)
                }
            }
            if selection.count > 0 {
                Button("Delete") {
                    showDeleteAlert = true
                }
            }
        }
        .alert(isPresented: $showDeleteAlert, content: {deleteAlert})
        .toolbar {
            Button {
                assetToEdit = Asset.withID(selection.first!, in: viewContext)
            } label: {
                Image(systemName: "square.and.pencil")
            }
            .disabled(selection.count != 1)
        }
        
        
    }
    
    private var currentPrice: Double {
        assets.compactMap { ($0.ticker_?.price ?? 0.0) * Double($0.purchaseCount) }.reduce(0, +)
    }
    private var purchasePrice: Double {
        assets.compactMap { $0.purchasePrice * Double($0.purchaseCount) }.reduce(0, +)
    }
    private var profit: Double {
        (currentPrice/purchasePrice - 1) * 100
    }
    
    
    private var summaryView: some View {
        VStack {
            HStack {
                Text("Current price:")
                Text("\(currentPrice)")
                Spacer()
            }
            HStack {
                Text("Profit:")
                Text("\(currentPrice - purchasePrice) / \(profit)%")
                    .foregroundColor( profit > 0 ? .green : .red)
                Spacer()
            }

        }
        .padding([.horizontal, .top])
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
        // assets: FetchResaults. Need to ind right solution...
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
