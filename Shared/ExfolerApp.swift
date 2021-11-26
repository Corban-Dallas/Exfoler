//
//  ExfolerApp.swift
//  Shared
//
//  Created by Григорий Кривякин on 18.10.2021.
//

import SwiftUI

@main
struct ExfolerApp: App {
    let context = PersistenceController.shared.container.viewContext
    @StateObject var searchEngine = SearchEngine()
    @StateObject var assetsUpdater = TickersBackgroundUpdater(context: PersistenceController.shared.container.viewContext)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, context)
                .environmentObject(searchEngine)
                //.environmentObject(assetsUpdater)
        }
    }
}
