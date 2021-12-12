//
//  ContentView.swift
//  Shared
//
//  Created by Григорий Кривякин on 18.10.2021.
//

import SwiftUI
import CoreData
import Combine

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var searchEngine: SearchEngine

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Portfolio.name_, ascending: true)],
        animation: .default)
    private var portfolios: FetchedResults<Portfolio>
    
    var body: some View {
        NavigationView {
            VStack {
                searchField
                List {
                    Section(header: Text("Tickers")) {
                        NavigationLink(destination: TickersView()) {
                            Label("All tickers", systemImage: "list.bullet.rectangle")
                        }
                    }
                    portfolioSection
                }
                .toolbar {
                    ToolbarItemGroup {
                        Button(action: addPortfolio) {
                            Label("Add portfolio", systemImage: "plus")
                        }
                        Button(role: .destructive, action: deleteAllPortfolios) {
                            Label("Delete all", systemImage: "trash")
                        }

                    }
                }
            }
        }
    }
    
    // MARK: Search
    @State var searchText: String = ""
    @State private var showSearchResults = false

    private var searchField: some View {
        ZStack {
            NavigationLink(destination: SearchResultsView(), isActive: $showSearchResults) {
                // Empty
            }.opacity(0)
            
            SearchField(text: $searchText) { _ in } onCommit: {
                searchEngine.searchAssets(text: searchText)
                showSearchResults = true
            }
            .padding(.horizontal, 15)
        }
    }
    
    // MARK: Portfolio list
    private var portfolioSection: some View {
        Section(header: Text("Portfolios")) {
            NavigationLink(destination: AssetsView()) {
                Label("All assets", systemImage: "square.grid.2x2")
            }
            ForEach(portfolios) { portfolio in
                NavigationLink(destination: AssetsView(portfolio: portfolio)) {
                    Label(portfolio.name, systemImage: "case")
                }
                .onDrop(of: [Asset.draggableType, TickerInfo.draggableType], isTargeted: nil) { providers in
                    dropAssets(providers: providers, to: portfolio)
                }
                .contextMenu {
                    Button("Delete") {
                        viewContext.delete(portfolio)
                        try? viewContext.save()
                    }
                }
            }
        }
    }
    
    // MARK: - User intents
    private func addPortfolio() {
        withAnimation {
            let newPortfolio = Portfolio(context: viewContext)
            newPortfolio.name = "New portfolio"
            try? viewContext.save()
        }
    }
    
    private func deletePortfolios(offsets: IndexSet) {
        withAnimation {
            offsets.map { portfolios[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
    
    private func deleteAllPortfolios() {
        deletePortfolios(offsets: IndexSet(portfolios.indices))
    }
    
    // MARK: Drag and drop
    private func dropAssets(providers: [NSItemProvider], to portfolio: Portfolio) -> Bool {
        let assetProviders = providers.filter {
            $0.hasItemConformingToTypeIdentifier(Asset.draggableType.identifier) ||
            $0.hasItemConformingToTypeIdentifier(TickerInfo.draggableType.identifier)
        }
        Asset.fromItemProviders(assetProviders, context: viewContext) { assets in
            assets.forEach {  $0.portfolio = portfolio }
            try? viewContext.save()
        }
        return true
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
