//
//  BuddyRecommendations.swift
//  TravelConnect
//
//  Created by Cube on 10/29/23.
//

import SwiftUI

// A SwiftUI view that provides user recommendations.
struct RecommendationsView: View {
    @State private var recommendedUsers: [String] = []    // An array to store recommended user emails.
    @ObservedObject var viewModel: UserProfileViewModel   // ViewModel to handle user profile operations.
    
    var body: some View {
        VStack {
            List {
                // Section for recommended TripBuddies.
                Section(header: Text("TripBuddies")) {
                    ForEach(recommendedUsers, id: \.self) { user in
                        Text(user)
                    }
                }
    
            }
            .navigationTitle("Recommendations")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(GroupedListStyle())
            .onAppear {
                self.fetchRecommendations()  // Fetch recommendations when the view appears.
            }
        }
    }
    
    // Fetches recommendations based on interests.
    func fetchRecommendations() {
        let group = DispatchGroup()
        
        var currentUserInterests: [String] = []
        var allUsersInterests: [String: [String]] = [:]
        
        group.enter()
        viewModel.fetchCurrentUserInterests { result in
            switch result {
            case .success(let interests):
                currentUserInterests = interests
            case .failure(let error):
                print(error.localizedDescription)
            }
            group.leave()
        }
        
        group.enter()
        viewModel.fetchOtherUsersInterests { result in
            switch result {
            case .success(let interests):
                allUsersInterests = interests
            case .failure(let error):
                print(error.localizedDescription)
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            // Clear previous recommendations.
            recommendedUsers.removeAll()
            
            // Process and filter the recommendations based on common interests.
            for (userEmail, interests) in allUsersInterests {
                let commonInterests = Set(interests).intersection(currentUserInterests)
                if commonInterests.count > 0 {
                    recommendedUsers.append(userEmail)
                }
            }
        }
    }
}

