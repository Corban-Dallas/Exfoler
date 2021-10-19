//
//  exfolioApp.swift
//  exfolio
//
//  Created by Григорий Кривякин on 19.10.2021.
//

import SwiftUI

@main
struct exfolioApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
