//
//  ContentView.swift
//  TravelConnect
//
//  Created by Cube on 10/18/23.
//

import SwiftUI

struct ContentView: View {
    // ViewModel to manage authentication-related actions and states.
    @ObservedObject var viewModel: AuthViewModel
    // ViewModel to manage user profile-related actions and states, initialized with an AuthViewModel instance.
    @StateObject var userProfileViewModel = UserProfileViewModel(authViewModel: AuthViewModel())
    //MARK: - CoreData Singlton
    @ObservedObject var tripDetailViewModel:TripDetailViewModel = TripDetailViewModel()
    @ObservedObject var mapViewModel:MapViewModel = MapViewModel()
    @ObservedObject var conversationViewModel: ConversationsViewModel = ConversationsViewModel(authViewModel: AuthViewModel())
    @ObservedObject var authViewModel: AuthViewModel = AuthViewModel()
    let persistenceController = PersistenceController.shared
    

    var body: some View {
        // Tab view for the core navigation of the appplication
        TabView {
            // Tab 1 - Conversations
            NavigationView {
                ConversationsListView()
                    .environmentObject(tripDetailViewModel)
                    .environmentObject(mapViewModel)
                    .environmentObject(conversationViewModel)
                    .environmentObject(authViewModel)
            }
            .tabItem {
                Label("Chats", systemImage: "bubble.right")
            }

            // Tab 2 -
            NavigationView {
                TripListView()
                    .environmentObject(tripDetailViewModel)
                    .environmentObject(mapViewModel)
                    .environmentObject(conversationViewModel)
                    .environmentObject(authViewModel)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
            .tabItem {
                Label("Trip", systemImage: "list.bullet.rectangle.portrait")
            }
            // Tab 3 - Recommendations
            NavigationView {
                RecommendationsView(viewModel: userProfileViewModel)
            }
            .tabItem {
                Label("Recommendations", systemImage: "star")
            }
            // Tab 4 - Settings
            NavigationView {
                SettingsView(viewModel: viewModel)
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }.accentColor(Color(red: 0.0196, green: 0.2941, blue: 0.2863))
    }
}

#Preview {
    ContentView(viewModel: AuthViewModel())
}

