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

    static func fromItemProviders(_ itemProviders: [NSItemProvider], context: NSManagedObjectContext? = nil, completion: @escaping ([Asset]) -> Void) {
        let context = context ?? PersistenceController.shared.container.viewContext
        let typeIdentifier = Self.draggableType.identifier
        let filteredProviders = itemProviders.filter {
            $0.hasItemConformingToTypeIdentifier(typeIdentifier)
        }
        
        let group = DispatchGroup()
        var result = [Int: Asset]()

        for (index, provider) in filteredProviders.enumerated() {
            group.enter()
            provider.loadDataRepresentation(forTypeIdentifier: typeIdentifier) { (data, error) in
                defer { group.leave() }
                guard let data = data else { return }
                let decoder = JSONDecoder()
                guard let id = try? decoder.decode(Asset.ID.self, from: data)
                else { return }
                print("Decoded ID", id.uuidString)
                result[index] = Asset.withID(id, in: context)
            }
        }

        group.notify(queue: .global(qos: .userInitiated)) {
            let assets = result.keys.sorted().compactMap { result[$0] }
            DispatchQueue.main.async {
                completion(assets)
            }
        }


    }
    
    var itemProvider: NSItemProvider {
        let provider = NSItemProvider()
        provider.registerDataRepresentation(forTypeIdentifier: Self.draggableType.identifier,
                                            visibility: .all) {
            do {
                
                let data = try JSONEncoder().encode(self.id)
                print("Encoded ID", self.id.uuidString)
                $0(data, nil)
            } catch {
                $0(nil, error)
            }
            return nil
        }
        return provider
    }
}
