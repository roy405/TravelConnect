//
//  BuddyRecommendations.swift
//  TravelConnect
//
//  Created by Cube on 10/29/23.
//

import SwiftUI

struct RecommendationsView: View {
    @State private var recommendedUsers: [String] = []
    @ObservedObject var viewModel: UserProfileViewModel


    var body: some View {
        VStack {
            Text("Recommendations")
                .font(.largeTitle)
                .padding(.top)

            List {
                Section(header: Text("TripBuddies")) {
                    ForEach(recommendedUsers, id: \.self) { user in
                        Text(user)
                    }
                }

                Section(header: Text("Places")) {
                    // Place dummy data here as placeholders.
                    // Replace with actual data later.
                    ForEach(["Place 1", "Place 2", "Place 3"], id: \.self) { place in
                        Text(place)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .onAppear {
                self.fetchRecommendations()
            }
        }
    }

    func fetchRecommendations() {
        let group = DispatchGroup()

        var currentUserInterests: [String] = []
        var allUsersInterests: [String: [String]] = [:]

        group.enter()
        viewModel.fetchCurrentUserInterests { interests in
            currentUserInterests = interests
            group.leave()
        }

        group.enter()
        viewModel.fetchOtherUsersInterests { interests in
            allUsersInterests = interests
            group.leave()
        }

        group.notify(queue: .main) {
            // Clear previous recommendations
            recommendedUsers.removeAll()

            // Once both fetches are done, process the recommendations
            for (userEmail, interests) in allUsersInterests {
                let commonInterests = Set(interests).intersection(currentUserInterests)
                if commonInterests.count > 0 {
                    recommendedUsers.append(userEmail)
                }
            }
        }
    }
}
