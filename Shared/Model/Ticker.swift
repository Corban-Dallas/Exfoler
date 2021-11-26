//
//  Ticker.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 26.11.2021.
//

import Foundation
import CoreData

extension Ticker {
    public var id: UUID {
        get {
            if id_ == nil { id_ = UUID() }
            return id_! }
        set { id_ = newValue }
    }
//
    var symbol: String {
        get { symbol_ ?? "N/A"}
        set { symbol_ = newValue }
    }
    
    var name: String {
        get { name_ ?? "N/A"}
        set { name_ = newValue }
    }
        
    var currency: String {
        get { currency_ ?? "N/A" }
        set { currency_ = newValue }
    }
    
    var market: String {
        get { market_ ?? "N/A" }
        set { market_ = newValue}
    }
    
    var locale: String {
        get { locale_ ?? "N/A" }
        set { locale_ = newValue }
    }
    
    var type: String {
        get { type_ ?? "N/A" }
        set { type_ = newValue }
    }
    
    var price: Double {
        get { price_ }
        set { price_ = newValue }
    }
    
    var lastTimeUpdated: Date {
        get { lastTimeUpdated_ ?? Date(timeIntervalSince1970: 0)}
        set { lastTimeUpdated_ = newValue }
    }
    
    static func fromInfo(_ info: TickerInfo, context: NSManagedObjectContext) -> Ticker {
        let request = NSFetchRequest<Ticker>(entityName: "Ticker")
        request.predicate = NSPredicate(format: "symbol_ = %@", info.ticker)
        guard let ticker = try? context.fetch(request).first else {
            let ticker = Ticker(context: context)
            ticker.symbol = info.ticker
            ticker.name = info.name
            ticker.currency = info.currency
            ticker.type = info.type
            ticker.market = info.market
//            try? context.save()
            return ticker
        }
        return ticker
    }
}
