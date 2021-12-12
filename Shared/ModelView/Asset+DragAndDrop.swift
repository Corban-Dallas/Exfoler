//
//  Asset+ItemProvider.swift
//  Exfoler (macOS)
//
//  Created by Григорий Кривякин on 02.11.2021.
//

import Foundation
import UniformTypeIdentifiers
import CoreData

extension Asset {
    static var draggableType = UTType(exportedAs: "Grigory-Krivyakin.Exfoler.asset")
    
    // Provider for drag and drop this asset by ID in main context
    var itemProvider: NSItemProvider {
        let provider = NSItemProvider()
        provider.registerDataRepresentation(forTypeIdentifier: Self.draggableType.identifier,
                                            visibility: .all) {
            do {
                let data = try JSONEncoder().encode(self.id)
                $0(data, nil)
            } catch {
                $0(nil, error)
            }
            return nil
        }
        return provider
    }
    
    // Function transforms apropriate item providers into Asset in parallel and calls complite clouser on result
    static func fromItemProviders(_ itemProviders: [NSItemProvider], context: NSManagedObjectContext, complition: @escaping ([Asset]) -> Void) {
        // Filter providers to match only Asset and AssetInfo providers
        let filteredProviders = itemProviders.filter {
            $0.hasItemConformingToTypeIdentifier(Asset.draggableType.identifier) ||
            $0.hasItemConformingToTypeIdentifier(TickerInfo.draggableType.identifier)
        }

//        let group = DispatchGroup()
        // Arrange dict of future Assets
        var result = [Int: Asset]()
        DispatchQueue.global(qos: .userInitiated).sync {
            for (index, provider) in filteredProviders.enumerated() {
                // Depending on provider's type, transform provider into Asset and place it into arranged dict.
                switch provider.registeredTypeIdentifiers.first {
                case Asset.draggableType.identifier:
                    // Transform from Asset item provider
                    provider.loadDataRepresentation(forTypeIdentifier: Asset.draggableType.identifier) { (data, error) in
                        guard let data = data else { return }
                        let decoder = JSONDecoder()
                        guard let id = try? decoder.decode(Asset.ID.self, from: data)
                        else { return }
                        result[index] = Asset.withID(id, in: context)
                    }
                case TickerInfo.draggableType.identifier:
                    // Transform from AssetInfo item provider
                    provider.loadDataRepresentation(forTypeIdentifier: TickerInfo.draggableType.identifier) { (data, error) in
                        guard let data = data else { return }
                        let decoder = JSONDecoder()
                        guard let tickerInfo = try? decoder.decode(TickerInfo.self, from: data) else { return }
                        result[index] = Asset.fromInfo(tickerInfo, in: context)
                    }
                default:
                    break
                }
            }
            DispatchQueue.main.async {
                let assets = result.keys.sorted().compactMap { result[$0] }
                DispatchQueue.main.async {
                    complition(assets)
                }
            }
        }
    }
    
//    static func fromItemProviders(_ itemProviders: [NSItemProvider], context: NSManagedObjectContext, complition: @escaping ([Asset]) -> Void) {
//        // Filter providers to match only Asset and AssetInfo providers
//        let filteredProviders = itemProviders.filter {
//            $0.hasItemConformingToTypeIdentifier(Asset.draggableType.identifier) ||
//            $0.hasItemConformingToTypeIdentifier(TickerInfo.draggableType.identifier)
//        }
//
//        let group = DispatchGroup()
//        // Arrange dict of future Assets
//        var result = [Int: Asset]()
//
//        for (index, provider) in filteredProviders.enumerated() {
//            group.enter()
//            // Depending on provider's type, transform provider into Asset and place it into arranged dict.
//            switch provider.registeredTypeIdentifiers.first {
//            case Asset.draggableType.identifier:
//                // Transform from Asset item provider
//                provider.loadDataRepresentation(forTypeIdentifier: Asset.draggableType.identifier) { (data, error) in
//                    defer { group.leave() }
//                    guard let data = data else { return }
//                    let decoder = JSONDecoder()
//                    guard let id = try? decoder.decode(Asset.ID.self, from: data)
//                    else { return }
//                    result[index] = Asset.withID(id, in: context)
//                }
//            case TickerInfo.draggableType.identifier:
//                // Transform from AssetInfo item provider
//                provider.loadDataRepresentation(forTypeIdentifier: TickerInfo.draggableType.identifier) { (data, error) in
//                    defer { group.leave() }
//                    guard let data = data else { return }
//                    let decoder = JSONDecoder()
//                    guard let tickerInfo = try? decoder.decode(TickerInfo.self, from: data)
//                    else { return }
//                    result[index] = Asset.fromInfo(tickerInfo, in: context)
//                }
//            default:
//                group.leave()
//                break
//            }
//        }
//        group.notify(queue: .global(qos: .userInitiated)) {
//            let assets = result.keys.sorted().compactMap { result[$0] }
//            DispatchQueue.main.async {
//                complition(assets)
//            }
//        }
//    }

}
