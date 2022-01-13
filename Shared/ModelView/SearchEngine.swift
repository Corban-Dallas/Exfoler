//
//  DataFetcher.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 21.10.2021.
//
import Foundation
import CoreData
import Combine

@MainActor
class SearchEngine: ObservableObject {
    // Assign external API confroming to AssetsProvider protocol as a source of assets
    private let assetsProvider: AssetsProvider = PolygonAPI.shared
    
    @Published var isSearching = false
    @Published var searchResults: [TickerInfo] = []
//    private let context: NSManagedObjectContext
    private var cancellableSearch: AnyCancellable?
//
//    init(context: NSManagedObjectContext) {
//        // Create a child context to separate searched results from main context
//        self.context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        self.context.parent = context
//    }
    // Search all assets related with the text and store them in searchResults
    public func searchAssets(text: String) {
        isSearching = true
        clearResults()
        cancellableSearch = assetsProvider.tickers(search: text)
            .print()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isSearching = false
            } receiveValue: { [weak self] assetsInfo in
                self?.searchResults.append(contentsOf: assetsInfo)
            }
    }
    
    private func clearResults() {
        searchResults = []
    }
}
