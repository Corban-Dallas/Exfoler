//
//  TickerInfo+ItemProvider.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 12.11.2021.
//

import Foundation
import UniformTypeIdentifiers

extension TickerInfo {
    static var draggableType = UTType(exportedAs: "Grigory-Krivyakin.Exfoler.assetInfo")
    
    var itemProvider: NSItemProvider {
        let provider = NSItemProvider()
        provider.registerDataRepresentation(forTypeIdentifier: Self.draggableType.identifier,
                                            visibility: .all) {
            do {
                let data = try JSONEncoder().encode(self)
                $0(data, nil)
            } catch {
                $0(nil, error)
            }
            return nil
        }
        return provider
    }
}
