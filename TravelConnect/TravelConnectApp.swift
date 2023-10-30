//
//  TravelConnectApp.swift
//  TravelConnect
//
//  Created by Cube on 10/18/23.
//

import SwiftUI
import Firebase

@main
// The main entry point for the TravelConnect App.
struct TravelConnectApp: App {
    // Adapter to use AppDelegate in the new SwiftUI life cycle.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // Authentication ViewModel to manage authentication state.
    @StateObject var viewModel = AuthViewModel()
    
    // State to control the visibility of the splash screen.
    @State private var showSplashScreen = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Display loading screen while the app is initializing.
                if showSplashScreen {
                    LoadingScreen()
                } else {
                    // Display the main content if user is signed in, else show the login view.
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
    
    // Hides the splash screen after a delay.
    func hideSplashScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showSplashScreen = false
            }
        }
    }
}

// AppDelegate to configure and setup services when the app launches.
class AppDelegate: NSObject, UIApplicationDelegate {
    // This method is called when the app completes its launch.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase when the app starts.
        FirebaseApp.configure()
        return true
    }
}

