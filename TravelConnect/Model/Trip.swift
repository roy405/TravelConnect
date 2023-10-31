//
//  Trip.swift
//  TravelConnect
//
//  Created by Yangru Guo on 28/10/2023.
//

import Foundation
import MapKit
import CoreData

struct Trip: Hashable, Codable, Identifiable {
    var id:UUID = UUID()
    var conversationID: String?
    var type:String = ""
    var date:Date = Date()
    var dateString:String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
    var tripInfo:String = ""
    var placesOfInterest:[PlaceOfInterest] = []
    var topImage:Data = Data()
}

struct PlaceOfInterest: Hashable,Codable,Identifiable {
    var id:UUID = UUID()
    var time:Date = Date()
    var type:String = ""
    var name:String = ""
    var description:String = ""
    var mapItem:MapItem = MapItem(coordinates: Coordinate(latitude: 0, longitude: 0))
}

struct MapItem: Hashable,Codable{
    var coordinates:Coordinate
}

struct Coordinate: Hashable,Codable {
    var latitude:Double = 0.0
    var longitude:Double = 0.0
}

let coordinate = Coordinate(latitude: 37.7749, longitude: -122.4194)
let mapItem = MapItem(coordinates: coordinate)
let placeOfInterest = PlaceOfInterest(time: Date(), type: "Landmark", name: "Golden Gate Bridge", description: "An iconic bridge in San Francisco", mapItem: mapItem)
let staticTrip = Trip(type: "Sightseeing", date: Date(), tripInfo: "A trip to San Francisco", placesOfInterest: [placeOfInterest],topImage: (UIImage(named: "rivertest")?.pngData())!)
