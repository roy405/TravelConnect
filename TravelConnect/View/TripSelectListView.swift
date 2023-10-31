//
//  TripSelectListView.swift
//  TravelConnect
//
//  Created by Cube on 10/31/23.
//

import SwiftUI

struct TripSelectListView: View {
    @Binding var trips: [Trip]
    var selectedTrip: (Trip) -> Void

    var body: some View {
        
        List(trips, id: \.id) { trip in
            Button(action: {
                self.selectedTrip(trip)
            }) {
                Text(trip.type)
            }
        }
    }
}

