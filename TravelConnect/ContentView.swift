//
//  ContentView.swift
//  TravelConnect
//
//  Created by Cube on 10/18/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        TabView {
            NavigationView {
                ConversationsListView(viewModel: ConversationsViewModel(authViewModel: viewModel))
            }
            .tabItem {
                Label("Tab 1", systemImage: "1.circle")
            }

            // Tab 2
            Text("Tab Content 2")
                .tabItem {
                    Label("Tab 2", systemImage: "2.circle")
                }

            // Tab 3
            Text("Tab Content 3")
                .tabItem {
                    Label("Tab 3", systemImage: "3.circle")
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

