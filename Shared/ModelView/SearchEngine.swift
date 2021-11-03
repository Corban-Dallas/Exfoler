//
//  DataFetcher.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 21.10.2021.
//
import SwiftUI
import Foundation
import Combine
import CoreData
import PolygonKit

class SearchEngine: ObservableObject {
    @Published var isSearching = false
    @Published var searchResults: [Asset] = []
    var context: NSManagedObjectContext

    private var cancellableSearch: AnyCancellable?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public func searchAssets(text: String) {
        isSearching = true
        searchResults = []
        cancellableSearch = PolygonAPI.tickers(search: text)
            .print()
            .sink { [weak self] error in
                self?.isSearching = false
                try? self?.context.save()
//                do {
//                    try self!.context.save()
//                    print("Saved")
//                } catch {
//                    print("Save context error:", error)
//                }
            } receiveValue: { [weak self] value in
                let tickers: [Asset]? = value.results?.map {
                    let asset = Asset(context: self!.context)
                    asset.ticker = $0.ticker
                    asset.name = $0.name
                    asset.market = $0.market
                    asset.locale = $0.locale
                    asset.type_ = $0.type
                    asset.currency = $0.currency_name
                    return asset
                }
                if let tickers = tickers {
                    self?.searchResults.append(contentsOf: tickers)
                }
        }
    }
}
