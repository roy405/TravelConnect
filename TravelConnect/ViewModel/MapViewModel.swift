//
//  MapViewModel.swift
//  TravelConnect
//
//  Created by Yangru Guo on 30/10/2023.
//

import Foundation
import MapKit
import SwiftUI

enum MapViewMode {
    case placeOfInterest
    case route
}

class MapViewModel:ObservableObject{
    
    @Published var cameraPosition: MapCameraPosition = .automatic
    @Published var selectedResult:MKMapItem?
    @Published var routePolyLineCoordinates:[CLLocationCoordinate2D]?
    @Published var vehcleTravelRoute:MKRoute?
    @Published var visibleRegion:MKCoordinateRegion?
    
    func search(for query: String, within visibleRegion: MKCoordinateRegion, completion: @escaping ([MKMapItem]?) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = visibleRegion
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                completion(response.mapItems)
            } else if let error = error {
                print("Search error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func getDirections(from start:MKMapItem, to end:MKMapItem) -> MKRoute? {
        let request = MKDirections.Request()
        request.source = start
        request.destination = end
        //        request.source = MKMapItem(placemark: MKPlacemark(coordinate: .parking))
        //        request.destination = selectedResult
        Task{
            let direction = MKDirections(request: request)
            let response = try? await direction.calculate()
            return response?.routes.first
        }
        return nil
    }
}
