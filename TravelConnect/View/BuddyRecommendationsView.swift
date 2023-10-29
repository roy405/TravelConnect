//
//  BuddyRecommendations.swift
//  TravelConnect
//
//  Created by Cube on 10/29/23.
//

import SwiftUI

struct RecommendationsView: View {
    @State private var recommendedUsers: [String] = []

    var body: some View {
        List(recommendedUsers, id: \.self) { user in
            Text(user)
        }
        .onAppear {
            self.fetchRecommendations()
        }
    }

    func fetchRecommendations() {
        // Call the server or cloud function to get the recommended users
        // Update the `recommendedUsers` state variable
    }
}
