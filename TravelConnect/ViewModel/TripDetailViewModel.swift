//
//  TripDetailViewModel.swift
//  TravelConnect
//
//  Created by Yangru Guo on 28/10/2023.
//

import Foundation
import SwiftUI
import MapKit
import CoreData

class TripDetailViewModel:ObservableObject {
    
    @Published var allTrips:[Trip] = []
    @Published var currentViewingTrip:Trip = Trip()
    @Published var topImage:UIImage?
    let persistenceController = PersistenceController.shared
    
    func addPlaceToTrip(placeOfInterest:MKMapItem,time:Date,description:String,type:String){
        let newPlace = PlaceOfInterest(
            time: time,
            type: type,
            name: placeOfInterest.name ?? "Unknown",
            description: description,
            mapItem: MapItem(
                coordinates:Coordinate(
                    latitude: placeOfInterest.placemark.coordinate.latitude,
                    longitude: placeOfInterest.placemark.coordinate.longitude
                )
            )
        )
        currentViewingTrip.placesOfInterest.append(newPlace)
    }
    
    func saveTrip(context:NSManagedObjectContext){
        persistenceController.addTrip(trip:currentViewingTrip,context: context)
        currentViewingTrip = Trip()
    }
    
    func hasConversationLinked(trip: Trip) -> Bool {
        print("Trip's conversationID is: \(String(describing: trip.conversationID))")
        
        if trip.conversationID != nil {
            return true
        } else {
            return false
        }
    }

    
    func fetchAllTrips(context:NSManagedObjectContext){
        let tripRecords = persistenceController.fetchAllRouteRecords(context: context)
        var trips:[Trip] = []
        for tripRecord in tripRecords{
            var trip = Trip()
            trip.id = tripRecord.id!
            trip.type = tripRecord.type!
            trip.date = tripRecord.date!
            trip.tripInfo = tripRecord.tripInfo!
            if let conversationID = tripRecord.conversationID {
                trip.conversationID = tripRecord.conversationID!
            }
            var placeOfInterest:[PlaceOfInterest] = []
            if let placeOfInterestSet = tripRecord.placeOfInterest as? Set<PlaceOfInterestRecord>{
                for placeRecord in placeOfInterestSet {
                    var place = PlaceOfInterest()
                    place.time = placeRecord.time!
                    place.type = placeRecord.type!
                    place.name = placeRecord.name!
                    place.description = placeRecord.placeDescription!
                    var coordinate:Coordinate = Coordinate()
                    coordinate.latitude = (placeRecord.mapItem?.coordinate!.latitude)!
                    coordinate.longitude = (placeRecord.mapItem?.coordinate!.longitude)!
                    place.mapItem = MapItem(coordinates: coordinate)
                    placeOfInterest.append(place)
                }
            }
            trip.placesOfInterest = placeOfInterest
            trip.topImage = tripRecord.topImage!
            trips.append(trip)
        }
        self.allTrips = trips
    }
    
    // Function that saves the current converation's ID to the selected trip
    // by referencing the tripid with the coredata trip id.
    func updateTripWithConversationID(tripID: UUID, conversationID: String, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<TripRecord> = TripRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tripID as CVarArg)

        if let tripToUpdate = try? context.fetch(fetchRequest).first {
            print("Found trip to update. \(tripID)")
            tripToUpdate.conversationID = conversationID
            try? context.save()
            print("Trip updated with conversationID. \(conversationID)")
        } else {
            print("Trip not found.")
        }
    }


    
    func deleteTrip(context:NSManagedObjectContext,trip:Trip){
        persistenceController.deleteTripRecord(trip: trip, context: context)
    }
    
    func getImageIconName(type:String) -> String {
        switch type.lowercased() {
        case "walking":
            return "figure.walk.circle"
        case "party":
            return "party.popper"
        case "swimming":
            return "figure.open.water.swim"
        case "fishing":
            return "figure.fishing"
        case "hiking":
            return "figure.hiking"
        case "archery":
            return "figure.archery"
        case "biking":
            return "bicycle"
        case "bird watching":
            return "bird"
        case "camping":
            return "tent"
        case "kayaking":
            return "sailboat"
        case "outdooryoga":
            return "figure.yoga"
        case "paddleboarding":
            return "figure.snowboarding"
        case "rockclimbing":
            return "figure.climbing"
        case "running":
            return "figure.run"
        case "skateboarding":
            return "skateboard"
        case "surfing":
            return "figure.surfing"
        case "dining":
            return "fork.knife"
        case "shopping":
            return "basket"
        case "parking":
            return "parkingsign.circle"
        case "gaming":
            return "gamecontroller"
        default:
            return "mappin.circle"
        }
    }
    
    func getColorForActivity(_ activity: String) -> Color {
        switch activity.lowercased() {
        case "walking", "hiking", "archery", "bird watching", "outdooryoga", "rockclimbing", "running", "skateboarding":
            return .green // Outdoor activities
        case "swimming", "fishing", "kayaking", "paddleboarding", "surfing":
            return .blue // Water activities
        case "party":
            return .purple // Leisure activities
        case "biking":
            return .orange // Sports activities
        case "camping":
            return .brown // Camping
        case "dining":
            return .red // Dining
        case "shopping":
            return .yellow // Shopping
        default:
            return .gray // Other or default color
        }
    }
}
