//
//  AssetsUpdater.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 08.11.2021.
//

import Foundation
import CoreData
import Combine
import PolygonKit

class AssetsUpdater: ObservableObject {
    @Published var status: String = "Idle"
    private let context: NSManagedObjectContext
    
    
    private let assetsProvider: AssetsProvider = PolygonAPI.shared
    private var subscriptions = Set<AnyCancellable>()
        
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func updateAssets(_ assets: [Asset]) {
        print("Start update assets")
        // Remove already updated assets
        let assets = assets.filter { $0.lastDayUpdated < Date() }
        
        // Create a set of tickers for update
        let tickers = Set<String>(assets.map(\.ticker))
        
        self.status = "Updating"
        tickers.forEach { ticker in
            assetsProvider.previousClose(ticker: ticker)
                //.print()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] error in
                    if let _ = self?.subscriptions.isEmpty {
                        self?.status = "Idle"
                        print("Stop update assets")
                    }
                    print()
                } receiveValue: { [weak self] closePrice in
                    let request = NSFetchRequest<Asset>(entityName: "Asset")
                    request.predicate = NSPredicate(format: "ticker_ = %@", ticker)
                    if let assets = try? self?.context.fetch(request) {
                        assets.forEach{ asset in
                            asset.currentPrice = closePrice
                            asset.lastDayUpdated = Date()
                        }
                        try? self?.context.save()
                    }
                }
                .store(in: &subscriptions)
        }
    }
}
