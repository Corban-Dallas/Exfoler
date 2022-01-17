//
//  PersistenceController+DataStore.swift
//  Exfoler
//
//  Created by Григорий Кривякин on 17.01.2022.
//

import Foundation
import CoreData

extension PersistenceController: DataStore {
    // Convert TickerInfo into Ticker and add to Portfolio
    public func add(_ ticker: TickerInfo, to portfolio: Portfolio) {
        let asset = Asset.fromInfo(ticker, in: moc)
        asset.portfolio = portfolio
        try? moc.save()
    }
    
    // Return all portfolios
    func allPortfolios() -> [Portfolio] {
        // Fetch all portfolios from database
        let request = NSFetchRequest<Portfolio>(entityName: "Portfolio")
        guard let result = try? moc.fetch(request) else { return [] }
        return Array(result)
    }
    
    // Create and return new Portfolio
    @discardableResult
    func newPortfolio(name: String? = nil) -> Portfolio {
        let portfolio = Portfolio(context: moc)
        portfolio.name_ = name
        try? moc.save()
        return portfolio
    }
    
    // Delete CoreData object
    func delete(_ object: NSManagedObject) {
        moc.delete(object)
        try? moc.save()
    }
}
