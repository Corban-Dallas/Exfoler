//
//  PortfolioView.swift
//  Exfoler
//
//  Created by Григорий Кривякин on 18.10.2021.
//

import SwiftUI
import CoreData

struct PortfolioView: View {
    var portfolio: Portfolio
    @FetchRequest var assets: FetchedResults<Asset>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    init(portfolio: Portfolio) {
        self.portfolio = portfolio
        let request = NSFetchRequest<Asset>(entityName: "Asset")
        request.predicate = NSPredicate(format: "portfolio.id_ = %@", portfolio.id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Asset.ticker_, ascending: true)]
        _assets = FetchRequest(fetchRequest: request, animation: .default)
    }
    
    var body: some View {
        List(assets) { asset in
            Text(asset.ticker)
        }
        .toolbar {
            addAssetButton
        }
    }
    
    private var addAssetButton: some View {
        Button {
            withAnimation {
                let newAsset = Asset(context: viewContext)
                newAsset.ticker = "AAPL"
                newAsset.id = UUID()
                newAsset.portfolio = portfolio

                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        } label: {
            Label("Add asset", systemImage: "plus")
        }
    }

}

//struct PortfolioView_Previews: PreviewProvider {
//    static var previews: some View {
//        PortfolioView()
//    }
//}
