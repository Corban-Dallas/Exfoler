//
//  ContentView.swift
//  Shared
//
//  Created by Григорий Кривякин on 18.10.2021.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Portfolio.name, ascending: true)],
        animation: .default)
    private var portfolios: FetchedResults<Portfolio>
    @State var searchText: String = ""

    var body: some View {
        NavigationView {
            portfolioList
            Text("Select a stock")

        }
    }
    
    // MARK: Build blocks
    private var portfolioList: some View {
        VStack {
            SearchField(text: $searchText)
                .padding(.horizontal, 15)
            List {
                Section(header: Text("Portfolios")) {
                    ForEach(portfolios) { portfolio in
                        NavigationLink(destination: PortfolioView(portfolio: portfolio)) {
                            Text(portfolio.name!)
                        }
                    }
                    .onDelete(perform: deletePortfolios)

                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: addPortfolio) {
                        Label("Add Stock", systemImage: "plus")
                    }
                }
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
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
