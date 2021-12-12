//
//  TickersBackgroundUpdater.swift
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
// Also automatically remove tickers from database which are not
// releted with any asset anymore.
class TickersBackgroundUpdater: ObservableObject {
    // Connecting external API to this updater
    private let assetsProvider: AssetsProvider = PolygonAPI.shared

    @Published var status: Status = .idle
    private var currentlyUpdatingTicker: Ticker? = nil
    private let context: NSManagedObjectContext
    
    // Threadsafe reading and writing set of assets to update
    private let concurrentTickerQueue = DispatchQueue(
        label: "Grigory-Krivyakin.Exfoler.updateAssetQueue",
        attributes: .concurrent)
    private var unsafeTickersToUpdate = Set<Ticker>()
    private var tickersToUpdate: Set<Ticker> {
        get {
            var tickers = Set<Ticker>()
            concurrentTickerQueue.sync { [weak self] in
                tickers = self?.unsafeTickersToUpdate ?? Set<Ticker>()
            }
            return tickers
        }
        set {
            concurrentTickerQueue.sync { [weak self] in
                self?.unsafeTickersToUpdate = newValue
            }
        }
    }
    

    // Publisher and subscriber for update assets' price (if needed) on every context save
    private var updater: AnyCancellable?
    
    init(context: NSManagedObjectContext) {
        self.context = context

        tickersToUpdate = getTickersNeedUpdate()
        updateTickers()
        
        // TODO: Need make thread safe (when updating assetToUpdate value)
        updater = NotificationCenter.default.publisher(for: .NSManagedObjectContextWillSave)
            .sink { [weak self] _ in
            
                guard let tickers = self?.getTickersNeedUpdate()
                else { return }
                
                // Update tickersToUpdate value
                self?.tickersToUpdate = tickers
                
                // Start update if needed
                if tickers.isEmpty { return }
                if self?.status == .idle {
                    self?.updateTickers()
                }
            }
    }
        
    private func getTickersNeedUpdate() -> Set<Ticker> {
        // Get all assets from database
        let request = NSFetchRequest<Ticker>(entityName: "Ticker")
        request.sortDescriptors = []
        
        guard let fetchResult = try? context.fetch(request)
        else { return Set<Ticker>() }
        
        var tickers = Set(fetchResult)
        
        // Remove tickers which not related to any asset anymore
        let tickersToDelete = tickers.filter { $0.relatedAssets!.count == 0 }
        tickers = tickers.filter { $0.relatedAssets!.count > 0 }

        tickersToDelete.filter { $0.relatedAssets!.count == 0 }.forEach {
            self.context.delete($0)
        }
        
        // Exclude already updated assets
        tickers = tickers
            .filter { !NSCalendar.current.isDateInToday($0.lastTimeUpdated) }
        
        // Exclude asset currently updating
        if let currentTicker = self.currentlyUpdatingTicker {
            tickers.remove(currentTicker)
        }
        
        return tickers
    }
    
    // Reqursivelly update all assets in tickersToUpdate set
    private func updateTickers() {
        if self.status == .idle {
            DispatchQueue.main.async { [weak self] in
                self?.status = .updating
                print("[TickerUpdater] Started.")
            }
        }
        // Get next asset to update or finish work and save context
        guard let ticker = safePopNextTicker() else {
            try? self.context.save()
            DispatchQueue.main.async { [weak self] in
                self?.status = .idle
                print("[TickerUpdater] Finished.")
            }
            return
        }
        
        getTickerPrice(ticker: ticker.symbol) { [weak self] closePrice in
            print("[TickerUpdater] Start update \(ticker.symbol)")
            if let context = self?.context, context.deletedObjects.contains(ticker) {
                print("[TickerUpdater] Skip \(ticker.symbol)")
                return
            }
            ticker.price = closePrice
            ticker.lastTimeUpdated = Date()
            self?.updateTickers()
        }
    }
    
    // Threadsafe popFirst() from set of assets to update
    private func safePopNextTicker() -> Ticker? {
        var ticker: Ticker? = nil
        concurrentTickerQueue.sync(flags: .barrier) { [weak self] in
            ticker = self?.unsafeTickersToUpdate.popFirst()
        }
        return ticker
    }
    
    // Recursive function to get single asset price. It calls itself after 60 sec, if price was not received.
    private func getTickerPrice(ticker: String, complition: @escaping (Double) -> Void) -> Void {
        assetsProvider.previousClose(ticker: ticker) { closePrice, error in
            if let error = error {
                switch error {
                case ExfolerError.requestsExceeded:
                    print("[TickerUpdater] Requests exceeded. Wait 60 sec.")
                    DispatchQueue.global(qos: .userInitiated)
                        .asyncAfter(deadline: .now() + .seconds(60)) { [weak self] in
                            self?.getTickerPrice(ticker: ticker, complition: complition)
                        }
                default:
                    complition(-1.0)
                    return
                }
            } else {
                complition(closePrice!)
            }
        }
    }
    
    enum Status {
        case idle, updating
    }

}
