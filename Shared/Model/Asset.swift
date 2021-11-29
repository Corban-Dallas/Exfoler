//
//  Asset.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 20.10.2021.
//

import Foundation
import CoreData

extension Asset {
    public var id: UUID {
        get {
            if id_ == nil { id_ = UUID() }
            return id_! }
        set { id_ = newValue }
    }
    
    var name: String {
        get { name_ ?? "N/A"}
        set { name_ = newValue }
    }
    
    var ticker: Ticker {
        get { ticker_ ?? PersistenceController.shared.placeholderTicker }
        set { ticker_ = newValue }
    }

    static func withID(_ id: Asset.ID, in context: NSManagedObjectContext) -> Asset {
        let request = NSFetchRequest<Asset>(entityName: "Asset")
        request.sortDescriptors = [NSSortDescriptor(key: "id_", ascending: true)]
        request.predicate = NSPredicate(format: "id_ = %@", id as CVarArg)
        let asset = (try? context.fetch(request)) ?? []
        if let asset = asset.first {
            print("Asset with ID is found.")
            return asset
        } else {
            //return Asset(context: context)
            return Asset(context: context)
        }
    }
    
    static func fromInfo(_ info: TickerInfo, in context: NSManagedObjectContext) -> Asset {
        let asset = Asset(context: context)
        asset.name = info.name
        asset.ticker = Ticker.fromInfo(info, context: context)
        return asset
    }
}
