//
//  TripListView.swift
//  TravelConnect
//
//  Created by Yangru Guo on 29/10/2023.
//

import SwiftUI

struct TripListView: View {
    @EnvironmentObject var tripDetailViewModel: TripDetailViewModel
    @EnvironmentObject var mapViewModel: MapViewModel
    @EnvironmentObject var conversationViewModel: ConversationsViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.managedObjectContext) private var context
    
    @State private var showingShareSheet = false
    @State private var itemsToShare: [Any] = []

    var body: some View {
        NavigationStack{
            List{
                ForEach(tripDetailViewModel.allTrips){ trip in
                    ZStack{
                        TripListItemView(trip:trip)
                        NavigationLink(value:trip){
                            EmptyView()
                        }
                        .opacity(0)
                    }
                    .swipeActions {
                        Button(action: {
                            if let index = tripDetailViewModel.allTrips.firstIndex(of: trip) {
                                tripDetailViewModel.allTrips.remove(at: index)
                                tripDetailViewModel.deleteTrip(context: context, trip: trip)
                            }
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red.opacity(0.6))
                    }
                    .swipeActions(edge: .leading) {
                        Button(action: {
                            itemsToShare = [trip.type]  // Assuming your Trip object has a 'name' property
                            showingShareSheet = true
                        }) {
                            ZStack {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                        }
                        .tint(.green.opacity(0.6))
                    }
                }
                .onDelete(perform: { indexSet in
                    for index in indexSet {
                        tripDetailViewModel.deleteTrip(context: context, trip: tripDetailViewModel.allTrips[index])
                    }
                })
            }
            .listStyle(.plain)
            .onAppear{
                tripDetailViewModel.fetchAllTrips(context: context)
            }
            .padding(.top)
            .navigationDestination(for: String.self) { targetView in
                if targetView == "Map View"{
                    MapView(isViewTripMap: true)
                        .environmentObject(tripDetailViewModel)
                        .environmentObject(mapViewModel)
                }
                else if targetView == "POI Detail View"{
                    MapView()
                        .environmentObject(tripDetailViewModel)
                        .environmentObject(mapViewModel)
                }
                else if targetView == "Image Gallery View"{
                    ImageGalleryView()
                        .environmentObject(tripDetailViewModel)
                }
                else if targetView == "Trip Detail View Editing Mode"{
                    TripDetailView(isEditingMode: true)
                        .environmentObject(tripDetailViewModel)
                        .environmentObject(mapViewModel)
                }
                else if targetView == "Add A Route"{
                    MapView(isEditingTripInfo: true)
                        .environmentObject(tripDetailViewModel)
                        .environmentObject(mapViewModel)
                }
            }
            .navigationDestination(for: PlaceOfInterest.self) { place in
                MapView(isViewingPlaceOfInterest: true,placeOfInterest:place)
                    .environmentObject(tripDetailViewModel)
                    .environmentObject(mapViewModel)
            }
            .navigationDestination(for: Trip.self){ trip in
                TripDetailView(trip:trip, isEditingMode:false)
                    .environmentObject(tripDetailViewModel)
                    .environmentObject(mapViewModel)
                    .environmentObject(conversationViewModel)
                    .environmentObject(authViewModel)
            }
            .navigationTitle("Route Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .cancellationAction) {
                    Menu(content: {
                        Button("Walking") {
                            
                        }
                        Button("Biking") {
                            
                        }
                        Button("Running"){
                            
                        }
                        Button("Fishing"){
                            
                        }
                    }, label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    })
                }
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(value:"Trip Detail View Editing Mode"){
                        Image(systemName: "plus.circle")
                    }
                }
            }
        }    .sheet(isPresented: $showingShareSheet) {
            ActivityViewController(activityItems: itemsToShare)
        }
    }
}


// Share modal
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) { }
}

