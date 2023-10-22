//
//  TravelConnectApp.swift
//  TravelConnect
//
//  Created by Cube on 10/18/23.
//

import SwiftUI
import Firebase

@main
struct TravelConnectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var viewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if viewModel.isSignedIn {
                ContentView(viewModel: viewModel)
            } else {
                LoginView(viewModel: viewModel)
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
