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
    let persistenceController = PersistenceController.shared
    

    var body: some View {
        // Tab view for the core navigation of the appplication
        TabView {
            // Tab 1 - Conversations
            NavigationView {
                ConversationsListView(viewModel: ConversationsViewModel(authViewModel: viewModel))
            }
            .tabItem {
                Label("Chats", systemImage: "bubble.right")
            }

            // Tab 2 -
            NavigationView {
                TripListView()
                    .environmentObject(tripDetailViewModel)
                    .environmentObject(mapViewModel)
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
        }
    }
}

#Preview {
    ContentView(viewModel: AuthViewModel())
}

