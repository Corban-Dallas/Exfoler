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

// When initializated, keeps price of all assets in databese
// in background (through provided context) up to date.
class AssetsUpdater: ObservableObject {
    // Connecting external API to this updater
    private let assetsProvider: AssetsProvider = PolygonAPI.shared

    @Published var status: Status = .idle
    private let context: NSManagedObjectContext

    // Publisher and subscriber for update assets' price (if needed) on every context save
    private var didSave = NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
    private var updater: AnyCancellable?
    private var skipNextContextSave = false
    
    private var subscriptions = Set<AnyCancellable>()

    init(context: NSManagedObjectContext) {
        self.context = context
        print("[AssetUpdater] Exfoler launched. Start update prices.")
        updateAll()
        
        updater = didSave.sink { [weak self] assets in
            print("[AssetUpdater] Context was saved. Start update prices.")
            self?.updateAll()
        }
    }
    
    enum Status {
        case idle, updating
    }
    
    // Update price of all assets in database
    private func updateAll() {
        if skipNextContextSave {
            skipNextContextSave = false
            return
        }
        // Manage status
        status = .updating
        defer { status = .idle }
        // Get all assets from database
        let request = NSFetchRequest<Asset>(entityName: "Asset")
        request.sortDescriptors = []
        let assets = try? context.fetch(request)
        
        guard var assets = assets
        else { return }
        
        // Remove already updated assets and return if all asssets are updated.
        assets = assets
            .filter { !NSCalendar.current.isDateInToday($0.lastDayUpdated) }
        if assets.isEmpty { return }
        
        // Concurently update all assets
        let group = DispatchGroup()
        
        let _ = DispatchQueue.global(qos: .userInitiated)
        DispatchQueue.concurrentPerform(iterations: assets.count) { index in
            group.enter()
            getAssetPrice(ticker: assets[index].ticker) { closePrice in
                defer { group.leave() }
                assets[index].currentPrice = closePrice
                assets[index].lastDayUpdated = Date()
                print("Subscriptions count \(self.subscriptions.count)")
            }
        }
        
        group.notify(queue: .global(qos: .userInitiated)) { [weak self] in
            self?.skipNextContextSave = true
            try? self?.context.save()
        }
    }
    
    // Recursive function to get single asset price. It calls itself after 60 sec, if price was not received.
    private func getAssetPrice(ticker: String, complition: @escaping (Double) -> Void) -> Void {
        assetsProvider.previousClose(ticker: ticker)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                switch response {
                case .failure:
                    print("Cant get price of \(ticker). Wait 60 seconds and try again")
                    DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + .seconds(60)) { [weak self] in
                        self?.getAssetPrice(ticker: ticker, complition: complition)
                    }
                default:
                    break
                }
            } receiveValue: { closePrice in
                complition(closePrice)
            }
            .store(in: &subscriptions)
    }
}
