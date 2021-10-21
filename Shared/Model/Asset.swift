//
//  Asset.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 20.10.2021.
//

import Foundation

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
}
