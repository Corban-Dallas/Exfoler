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
    
    var ticker: String {
        get { ticker_ ?? "Unknown" }
        set { ticker_ = newValue }
    }
    
    var name: String {
        get { name_ ?? "Unknown"}
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
    
    var currentPrice: Double {
        get { currentPrice_ }
        set { currentPrice_ = newValue }
    }
    
    static func withID(_ id: Asset.ID, in context: NSManagedObjectContext) -> Asset {
        let request = NSFetchRequest<Asset>(entityName: "Asset")
        request.sortDescriptors = [NSSortDescriptor(key: "id_", ascending: true)]
        request.predicate = NSPredicate(format: "id_ = %@", id as CVarArg)
        let asset = (try? context.fetch(request)) ?? []
        if let asset = asset.first {
            print("Asset with ID founded")
            return asset
        } else {
            print("Asset with ID not founded")
            let asset = Asset(context: context)
            return asset
        }
    }
}
