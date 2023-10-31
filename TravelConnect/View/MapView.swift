//
//  MapView.swift
//  TravelConnect
//
//  Created by Yangru Guo on 30/10/2023.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var tripDetailViewModel:TripDetailViewModel
    @EnvironmentObject var mapViewModel:MapViewModel
    @State private var searchResult:[MKMapItem]?
    @State private var searchQuery:String = ""
    
    @State private var center:CLLocationCoordinate2D?
    
    @State private var visibleRegion:MKCoordinateRegion?
    
    @State private var selectedResult:MKMapItem?
    
    @State private var route:MKRoute?
    
    @State private var position:MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    @State private var trip:Trip?
    @State var isEditingTripInfo:Bool = false
    @State var placeDescription:String = ""
    @State var timeOfVisit:Date = Date()
    var placeType:String{
        return tripTypes[selectedIndex]
    }
    @State var selectedIndex:Int = 0
    @State var isPickerVisible:Bool = false
    var tripTypes = ["walking","party","swimming","fishing","hiking","archery","biking","bird watching","camping","kayaking","outdooryoga","paddleboarding","rockclimbing","running","skateboarding","surfing","dining","shopping","parking","gaming"]
    let gradient = LinearGradient(
        colors:[.blue,.yellow,.green],
        startPoint: .leading,
        endPoint: .trailing
    )
    let stroke = StrokeStyle(
        lineWidth: 5,
        lineCap: .round,
        lineJoin: .round,
        dash: [10,10]
    )
    
    @State var isViewingPlaceOfInterest:Bool = false
    @State var placeOfInterest:PlaceOfInterest?
    @State var isViewTripMap:Bool = false
    
    
    var body: some View {
        //MARK: - Search Place Section
        if(isEditingTripInfo){
            VStack{
                HStack{
                    TextField("Start Search Place", text: $searchQuery)
                        .padding(.vertical,12)
                        .padding(.horizontal)
                        .background{
                            RoundedRectangle(cornerRadius: 10,style:.continuous)
                                .strokeBorder(.gray)
                        }
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        if let visibleRegion {
                            mapViewModel.search(for: searchQuery, within: visibleRegion) { searchResults in
                                if let searchResults = searchResults {
                                    self.searchResult = searchResults
                                }
                            }
                        }
                    }, label: {
                        Image(systemName: "magnifyingglass")
                            .imageScale(.large)
                    })
                }
                .padding(.top)
                .padding(.horizontal)
                Divider()
                HStack{
                    Spacer()
                    Button{
                        searchResult = []
                        if let visibleRegion {
                            mapViewModel.search(for: "Fishing", within: visibleRegion) { searchResults in
                                if let searchResults = searchResults {
                                    self.searchResult = searchResults
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "figure.fishing")
                            .resizable()
                            .frame(width: 20, height: 25)
                    }
                    .buttonStyle(.borderedProminent)
                    Button{
                        searchResult = []
                        if let visibleRegion {
                            mapViewModel.search(for: "Food", within: visibleRegion) { searchResults in
                                if let searchResults = searchResults {
                                    self.searchResult = searchResults
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "fork.knife")
                            .resizable()
                            .frame(width: 20, height: 25)
                    }
                    .buttonStyle(.borderedProminent)
                    Button{
                        searchResult = []
                        if let visibleRegion {
                            mapViewModel.search(for: "Beach", within: visibleRegion) { searchResults in
                                if let searchResults = searchResults {
                                    self.searchResult = searchResults
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "beach.umbrella")
                            .resizable()
                            .frame(width: 20, height: 25)
                    }
                    .buttonStyle(.borderedProminent)
                    Button{
                        searchResult = []
                        if let visibleRegion {
                            mapViewModel.search(for: "Parking", within: visibleRegion) { searchResults in
                                if let searchResults = searchResults {
                                    self.searchResult = searchResults
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "parkingsign")
                            .resizable()
                            .frame(width: 20, height: 25)
                    }
                    .buttonStyle(.borderedProminent)
                    Button{
                        searchResult = []
                        if let visibleRegion {
                            mapViewModel.search(for: "Swiming", within: visibleRegion) { searchResults in
                                if let searchResults = searchResults {
                                    self.searchResult = searchResults
                                }
                            }
                        }
                    } label: {
                        VStack{
                            Image(systemName: "figure.pool.swim")
                                .resizable()
                                .frame(width: 20, height: 25)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                .labelStyle(.iconOnly)
            }
        }
        
        //MARK: - MapView
        Map(position: $position,selection: $selectedResult){
            
            if let searchResult {
                ForEach(searchResult,id:\.self){ result in
                    Marker(item:result)
                }
                .annotationTitles(.hidden)
            }
            
            if let placeOfInterest {
                Marker("\(placeOfInterest.name)",coordinate: CLLocationCoordinate2D(latitude: placeOfInterest.mapItem.coordinates.latitude, longitude: placeOfInterest.mapItem.coordinates.longitude))
            }
            
            if isViewTripMap {
                ForEach(tripDetailViewModel.currentViewingTrip.placesOfInterest){ place in
                    Marker("\(place.name)",coordinate:CLLocationCoordinate2D(latitude: place.mapItem.coordinates.latitude, longitude: place.mapItem.coordinates.longitude))
                }
            }
            
            UserAnnotation()
        }
        .mapStyle(isViewingPlaceOfInterest ? .hybrid(elevation:.realistic):.standard(elevation:.realistic))
        
        //MARK: - Section For Preview And Add Place
        .safeAreaInset(edge: .bottom) {
            VStack{
                ItemLookAroundView(selectedResult:$selectedResult,route: route)
                    .frame(height:128)
                    .clipShape(RoundedRectangle(cornerRadius:10))
                    .padding([.top, .horizontal])
                if let selectedResult {
                    VStack{
                        
                        ZStack{
                            RoundedRectangle(cornerRadius: 10,style:.continuous)
                                .fill(Color.clear)
                                .frame(height:45)
                            DatePicker("Visit Time",selection: $timeOfVisit,in:Date()...)
                                .padding(.horizontal,10)
                            
                        }
                        
                        HStack{
                            Text("Activity Type")
                            Spacer()
                            
                            Picker("Place Type Picker", selection: $selectedIndex) {
                                ForEach(0..<tripTypes.count, id: \.self) { index in
                                    Text(tripTypes[index]).tag(index)
                                }
                            }
                            .pickerStyle(DefaultPickerStyle())
                            .cornerRadius(10)
                        }
                        .padding(.horizontal,10)
                        
                        TextField("Put description of the place here", text: $placeDescription)
                            .padding(10)
                            .background{
                                RoundedRectangle(cornerRadius: 10,style:.continuous)
                                    .fill(Color.white)
                                    .strokeBorder(.gray.opacity(0.5))
                                    .frame(height:45)
                            }
                        
                        Button(action: {
                            tripDetailViewModel.addPlaceToTrip(placeOfInterest:selectedResult,time:timeOfVisit,description:placeDescription,type:placeType)
                            dismiss()
                        }, label: {
                            ZStack{
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .frame(height:45)
                                Text("Add To Trip")
                            }
                        })
                    }
                    .padding(.horizontal)
                    .background(.thinMaterial.opacity(0.8))
                }
            }
            .background(.thinMaterial.opacity(0.8))
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onChange(of:searchResult){
            position = .automatic
        }
        .onMapCameraChange { context in
            visibleRegion = context.region
        }
        .mapControls{
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .onAppear{
            let locationManager = CLLocationManager()
            locationManager.requestWhenInUseAuthorization()
            
            if(isViewingPlaceOfInterest), let placeOfInterest {
                position = .camera (
                    MapCamera(
                        centerCoordinate: CLLocationCoordinate2D(
                            latitude: placeOfInterest.mapItem.coordinates.latitude,
                            longitude: placeOfInterest.mapItem.coordinates.longitude
                        ),
                        distance: 200,
                        heading: 240,
                        pitch: 60
                    )
                )
            }
        }
    }
}
