//
//  SettingsView.swift
//  TravelConnect
//
//  Created by Cube on 10/22/23.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: AuthViewModel
    @ObservedObject var userProfileViewModel = UserProfileViewModel(authViewModel: AuthViewModel())

    var body: some View {
        List {
            Section(header: Text("General")) {
                Text("Item 1")
                Text("Item 2")
                Text("Item 3")
            }
            
            Section(header: Text("User Profile")) {
                NavigationLink(destination: UserProfileView(viewModel: userProfileViewModel)) {
                    Text("View Profile")
                }
            }
            
            Section(header: Text("Account")) {
                Button(action: {
                    viewModel.logout()
                }) {
                    Text("Logout")
                        .foregroundColor(.red)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Settings")
        .onAppear {
            if let email = viewModel.currentUserEmail {
                userProfileViewModel.fetchUserProfile(email: email)
            }
        }
    }
}




