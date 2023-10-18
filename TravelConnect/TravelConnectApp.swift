//
//  TravelConnectApp.swift
//  TravelConnect
//
//  Created by Cube on 10/18/23.
//

import SwiftUI

@main
struct TravelConnectApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
