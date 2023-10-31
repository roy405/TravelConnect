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
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate{
    
    var window: UIWindow?
    // This method is called when the app completes its launch.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure Firebase when the app starts.
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        
        // Initialize your main view controller
        let mainViewController = UIHostingController(rootView: ContentView(viewModel: AuthViewModel()))

        // Create a UIWindow and set the main view controller as the root view controller
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = mainViewController
        self.window?.makeKeyAndVisible()
        
        
        return true
    }
    
    // Handle user's response to the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle user's response to the notification, e.g., open the main view
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            // The user tapped the notification, open the main view
            if let window = self.window {
                window.rootViewController = UIHostingController(rootView: ContentView(viewModel: AuthViewModel()))
            }
        }
        completionHandler()
    }
    

}

