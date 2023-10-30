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
    
    @State private var showSplashScreen = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplashScreen {
                    LoadingScreen()
                } else {
                    if viewModel.isSignedIn {
                        ContentView(viewModel: viewModel)
                    } else {
                        LoginView(viewModel: viewModel)
                    }
                }
            }
            .onAppear(perform: hideSplashScreen)
        }
    }
    
    func hideSplashScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showSplashScreen = false
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
