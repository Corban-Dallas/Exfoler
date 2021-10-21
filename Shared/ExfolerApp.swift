//
//  ExfolerApp.swift
//  Shared
//
//  Created by Григорий Кривякин on 18.10.2021.
//

import SwiftUI

@main
struct ExfolerApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var dataFetcher = DataFetcher()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(dataFetcher)
        }
    }
}
