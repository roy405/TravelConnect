//
//  ContentView.swift
//  TravelConnect
//
//  Created by Cube on 10/18/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: AuthViewModel
    @StateObject var userProfileViewModel = UserProfileViewModel(authViewModel: AuthViewModel())

    var body: some View {
        TabView {
            NavigationView {
                ConversationsListView(viewModel: ConversationsViewModel(authViewModel: viewModel))
            }
            .tabItem {
                Label("Chats", systemImage: "bubble.right")
            }

            // Tab 2
            NavigationView {
                WeatherForecastView(city: "Sydney")
            }
            .tabItem {
                Label("Forecast", systemImage: "sun")
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

