//
//  DataStore.swift
//  Exfoler
//
//  Created by Григорий Кривякин on 17.01.2022.
//

import Foundation
import CoreData

protocol DataStore {
    
    func allPortfolios() -> [Portfolio]
    
    @discardableResult
    func newPortfolio(name: String?) -> Portfolio
    
    func add(_ ticker: TickerInfo, to portfolio: Portfolio)
    
    func delete(_ object: NSManagedObject)
}
