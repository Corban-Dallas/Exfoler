//
//  DataFetcher.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 21.10.2021.
//
import SwiftUI
import Foundation
import Combine

class DataFetcher: ObservableObject {
    @Published var searchResults: [Asset]? = []
    @Environment(\.managedObjectContext) private var viewContext

    private var cancellableSearch: AnyCancellable?
    
    public func searchAssets(text: String) {
        searchResults = nil
        cancellableSearch = PolygonAPI.tickers(search: text).sink(receiveCompletion: { error in  print(error)},
                                                                  receiveValue: { [weak self] value in
            let tickers: [Asset] = value.results.map {
                let asset = Asset(context: self!.viewContext)
                asset.ticker = $0.ticker
                asset.name = $0.name
                return asset
            }
            self?.searchResults = tickers
            
                    
        })
    }
}
