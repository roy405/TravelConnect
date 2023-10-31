//
//  TripDetailView.swift
//  TravelConnect
//
//  Created by Yangru Guo on 27/10/2023.
//

import SwiftUI

struct TripDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var tripDetailViewModel:TripDetailViewModel
    @Environment(\.managedObjectContext) private var context
    @State var trip:Trip?
    @State var headings:[String] = ["Trip Description","Route Details","View On Map","Weather","Title"]
    @State var routeInfo:String?
    @State var topImage:UIImage?
    @State var placesOfInterest:[String] = ["a","b","c","d"]
    @State var isTripInfoExpanded:Bool = true
    @State var isMapViewPresented:Bool = false
    @State var isEditingMode:Bool
    @State var screenHeight:CGFloat = UIScreen.main.bounds.height
    @State var screenWidth:CGFloat = UIScreen.main.bounds.width
    @State var isEditingTripInfo:Bool = false
    @State var isEditingStart:Bool = false
    @State var isEditingTitleInfo:Bool = false
    
    @State var dummyForecasts: [Forecast] = [
        Forecast(id: UUID(), date: Date(), maxtemp_c: 23.5, mintemp_c: 15.2, conditionText: "Sunny"),
        Forecast(id: UUID(), date: Date().addingTimeInterval(86400), maxtemp_c: 25.0, mintemp_c: 17.3, conditionText: "Cloudy"),
        Forecast(id: UUID(), date: Date().addingTimeInterval(172800), maxtemp_c: 20.4, mintemp_c: 14.0, conditionText: "Rainy")
    ]
    
    var body: some View {
            ZStack{
                //MARK: - Image Background at Top
                ZStack{
                    VStack{
                        Image(uiImage: UIImage(data:tripDetailViewModel.currentViewingTrip.topImage) ?? UIImage(named:"rivertest")!) // to be changed ****
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:screenHeight * 4 / 3,height: screenHeight * 2 / 3)
                        Spacer()
                    }
                    .background(.thickMaterial)
                    .ignoresSafeArea()
                    //MARK: - Editing Mode Edit Image Bar
                    if (isEditingMode){
                        VStack{
                            NavigationLink(value:"Image Gallery View"){
                                ZStack{
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .frame(height:45)
                                    HStack{
                                        Image(systemName: "pencil")
                                        Text("Select An Image")
                                    }
                                    .foregroundColor(.blue)
                                    .padding()
                                }
                            }
                            Spacer()
                        }
                    }
                }
                ScrollView{
                    //MARK: - Placeholder to view background IMG
                    Rectangle()
                        .fill(Color.clear)
                        .frame(maxWidth: screenWidth)
                        .frame(height: screenHeight / 5)
                    
                    VStack{
                        //MARK: - Title Section
                        if isEditingMode {
                            Text(headings[4])
                                .font(.title3)
                                .frame(maxWidth:screenWidth)
                                .padding()
                                .background(Color.teal)
                                .sticky()
                            if (isEditingMode){
                                ZStack{
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .frame(height:45)
                                    Button(action: {
                                        isEditingTitleInfo.toggle()
                                    }, label: {
                                        HStack{
                                            Image(systemName: isEditingTitleInfo ? "square.and.arrow.down":"pencil")
                                            Text(isEditingTitleInfo ? "Save":"Edit Title")
                                        }
                                    })
                                    .foregroundColor(.blue)
                                    .padding()
                                }
                            }
                            if isEditingTitleInfo {
                                TextField("Edit text", text: $tripDetailViewModel.currentViewingTrip.type,axis: .vertical)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                                    .onSubmit {
                                        isEditingTitleInfo.toggle()
                                    }
                            }else{
                                Text(tripDetailViewModel.currentViewingTrip.type)
                                    .padding()
                            }
                        }
                        
                        //MARK: - Route Info Section
                        Text(headings[0])
                            .font(.title3)
                            .frame(maxWidth:screenWidth)
                            .padding()
                            .background(Color.teal)
                            .sticky()
                        if (isEditingMode){
                            ZStack{
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .frame(height:45)
                                Button(action: {
                                    isEditingTripInfo.toggle()
                                }, label: {
                                    HStack{
                                        Image(systemName: isEditingTripInfo ? "square.and.arrow.down":"pencil")
                                        Text(isEditingTripInfo ? "Save":"Edit Trip Description")
                                    }
                                })
                                .foregroundColor(.blue)
                                .padding()
                            }
                        }
                        if isEditingTripInfo {
                            TextField("Edit text", text: $tripDetailViewModel.currentViewingTrip.tripInfo,axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(5...)
                                .padding()
                                .onSubmit {
                                    isEditingTripInfo.toggle()
                                }
                        }else{
                            Text(tripDetailViewModel.currentViewingTrip.tripInfo)
                                .padding()
                        }

                        //MARK: - Expandable Route Details
                        ZStack{
                            Text(headings[1])
                                .font(.title3)
                                .frame(maxWidth:screenWidth)
                                .padding()
                                .background(Color.teal)
                            HStack {
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        isTripInfoExpanded.toggle()
                                    }
                                }) {
                                    Image(systemName: isTripInfoExpanded ? "arrowtriangle.down.fill":"arrowtriangle.forward.fill")
                                        .foregroundColor(.white)
                                }
                                .padding(.trailing)
                            }
                        }
                        .sticky()
                        if (isEditingMode){
                            NavigationLink(value:"Add A Route"){
                                ZStack{
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .frame(height:45)
                                    HStack{
                                        Image(systemName: "plus")
                                        Text("Add a route")
                                    }
                                    .foregroundColor(.blue)
                                    .padding()
                                    .zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                                }
                            }
                        }
                        if isTripInfoExpanded {
                            ForEach(tripDetailViewModel.currentViewingTrip.placesOfInterest, id: \.self) { place in
                                PlaceOfInterestView(pointOfInterest:place)
                                    .environmentObject(tripDetailViewModel)
                            }
                        }
                        if (isEditingMode){
                            Button(action: {
                                tripDetailViewModel.saveTrip(context: context)
                                isEditingStart = false
                                dismiss()
                            }, label: {
                                ZStack{
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .frame(height:45)
                                    HStack{
                                        Image(systemName: "square.and.arrow.down")
                                        Text("Save Route")
                                    }
                                }
                            })
                        }
                        if !isEditingMode {
                        //MARK: - Map View Link
                        Text(headings[2])
                            .font(.title3)
                            .frame(maxWidth:screenWidth)
                            .padding()
                            .background(Color.teal)
                            .sticky()
                        NavigationLink(value:"Map View"){
                            ZStack {
                                // Placeholder Image
                                Image("MapViewPlaceHolder")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                Text("Tap To View Details")
                                    .foregroundColor(.white)
                                    .font(.title)
                            }
                        }
                        
                        //MARK: - Weather View
                        Text(headings[3])
                            .font(.title3)
                            .frame(maxWidth:screenWidth)
                            .padding()
                            .background(Color.teal)
                            .sticky()
                            ScrollView(.horizontal){
                                HStack(spacing: 20) {
                                    ForEach(dummyForecasts, id: \.date) { forecast in
                                        DayWeatherView(forecast: forecast)
                                    }
                                }
                                .background(.thinMaterial)
                            }
                        }
                    }
                    .background(.thickMaterial)
                    .cornerRadius(20)
                }
                .coordinateSpace(name: "container")
                .padding(.top, UIApplication
                    .shared
                    .connectedScenes
                    .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                    .first { $0.isKeyWindow }?.safeAreaInsets.top)
                .frame(maxWidth: screenWidth)
                .onAppear{
                    if !isEditingMode,let trip {
                        tripDetailViewModel.currentViewingTrip = trip
                    } else if isEditingMode{
                        if !isEditingStart {
                            tripDetailViewModel.currentViewingTrip = Trip()
                            isEditingStart.toggle()
                        }
                    }
                }
            }
        
    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
}

struct Sticky: ViewModifier {
    @State private var frame: CGRect = .zero

    var isSticking: Bool {
        frame.minY < 0
    }

    func body(content: Content) -> some View {
        content
            .offset(y: isSticking ? -frame.minY : 0)
            .zIndex(isSticking ? .infinity : 0)
            .overlay(GeometryReader { proxy in
                let f = proxy.frame(in: .named("container"))
                Color.clear
                    .onAppear { frame = f }
                    .onChange(of: f) {
                        frame = f
                    }
            })
    }
}

extension View {
    func sticky() -> some View {
        modifier(Sticky())
    }
}