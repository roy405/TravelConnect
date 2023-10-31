//
//  SettingsView.swift
//  TravelConnect
//
//  Created by Cube on 10/22/23.
//

import SwiftUI

// View that displays various settings options for the user.
struct SettingsView: View {
    // The main authentication view model that handles user authentication-related tasks.
    @ObservedObject var viewModel: AuthViewModel
    // View model responsible for user profile-related actions and data.
    @ObservedObject var userProfileViewModel = UserProfileViewModel(authViewModel: AuthViewModel())
    
    var body: some View {
        // A list to display different settings sections.
        List {
            // General settings section.
            Section(header: Text("General")) {
                Text("Item 1")
                Text("Item 2")
                Text("Item 3")
            }
            // Section to navigate and view user's profile.
            Section(header: Text("User Profile")) {
                NavigationLink(destination: UserProfileView(viewModel: userProfileViewModel)) {
                    Text("View Profile")
                }
            }
            // Account-related actions, e.g., logout.
            Section(header: Text("Account")) {
                Button(action: {
                    viewModel.logout()
                }) {
                    Text("Logout")
                        .foregroundColor(.red)
                }
            }
        }
        .listStyle(GroupedListStyle())  // Styles the list in a grouped manner.
        .navigationTitle("Settings")    // Sets the title for the navigation bar.
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {                     // Action to perform when the view appears.
            if let email = viewModel.currentUserEmail {
                userProfileViewModel.fetchUserProfile(email: email)
            }
        }
    }
}



