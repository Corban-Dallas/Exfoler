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
    @EnvironmentObject var dataFetcher: SearchEngine

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Portfolio.name_, ascending: true)],
        animation: .default)
    private var portfolios: FetchedResults<Portfolio>
    
    var body: some View {
        NavigationView {
            VStack {
                searchField
                List {
                    portfolioSection
                }
                .toolbar {
                    addPortfolioItem
                    removeAllPortfoliosItem
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
//                print("Commit: \(searchText)")
                dataFetcher.searchAssets(text: searchText)
                showSearchResults = true
            }
            .padding(.horizontal, 15)
        }
    }
    
    // MARK: Portfolios list
    private var portfolioSection: some View {
        Section(header: Text("Portfolios")) {
            NavigationLink(destination: AssetsView()) {
                Text("All assets")
            }
            ForEach(portfolios) { portfolio in
                NavigationLink(destination: AssetsView(portfolio: portfolio)) {
                    Text(portfolio.name)
                }
                .onDrop(of: [Asset.draggableType], isTargeted: nil) { providers in
                    dropAssets(providers: providers, to: portfolio)
                }

            }
        }
    }
    // MARK: - Toolbar
    private var addPortfolioItem: ToolbarItem<Void, Button<Label<Text, Image>>> {
        ToolbarItem {
            Button(action: addPortfolio) {
                Label("Add portfolio", systemImage: "plus")
            }
        }
    }
    
    private var removeAllPortfoliosItem: ToolbarItem<Void, Button<Label<Text, Image>>> {
        ToolbarItem(placement: .destructiveAction) {
            Button {
                portfolios.forEach(viewContext.delete)
                do {
                    try viewContext.save()
                } catch {
                    print(error)
                }
            } label: {
                Label("Delete all", systemImage: "trash")
            }
        }
    }

    
    // MARK: - User intents
    private func addPortfolio() {
        withAnimation {
            let newPortfolio = Portfolio(context: viewContext)
            newPortfolio.name = "Portfolio \(portfolios.count)"
            newPortfolio.id = UUID()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deletePortfolios(offsets: IndexSet) {
        withAnimation {
            offsets.map { portfolios[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: Drag and drop
    private func dropAssets(providers: [NSItemProvider], to portfolio: Portfolio) -> Bool {
        let assetProviders = providers.filter {
            $0.hasItemConformingToTypeIdentifier(Asset.draggableType.identifier)
        }
        Asset.fromItemProviders(assetProviders, context: viewContext) { assets in
            assets.forEach {
                $0.portfolio = portfolio
            }
            do {
                try viewContext.save()
            } catch {
                print(error)
            }
        }
        return true
    }

}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
