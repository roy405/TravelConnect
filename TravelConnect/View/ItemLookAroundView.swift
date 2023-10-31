//
//  ItemInfoView.swift
//  TravelConnect
//
//  Created by Yangru Guo on 28/10/2023.
//

import SwiftUI
import MapKit

struct ItemLookAroundView: View {
    @State var lookAroundScene:MKLookAroundScene?
    @Binding var selectedResult:MKMapItem?
    @State var route:MKRoute?
//    private var travelTime:String?{
//        guard let route else { return nil }
//        let formatter = DateComponentsFormatter()
//        formatter.unitsStyle = .abbreviated
//        formatter.allowedUnits = [.hour,.minute]
//        return formatter.string(from: route.expectedTravelTime)
//    }
    
    var body: some View {
        if let selectedResult {
            LookAroundPreview(initialScene:lookAroundScene)
                .overlay(alignment:.bottomTrailing){
                    HStack{
                        Text("\(selectedResult.name ?? "")")
                        //                if let travelTime {
                        //                    Text(travelTime)
                        //                }
                    }
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(10)
                }
                .onAppear{
                    getLookAroundScene(selectedResult:selectedResult)
                }
                .onChange(of: selectedResult){
                    getLookAroundScene(selectedResult:selectedResult)
                }
            
        }
    }
    
    func getLookAroundScene(selectedResult:MKMapItem){
        lookAroundScene = nil
        Task{
            let request = MKLookAroundSceneRequest(mapItem: selectedResult)
            lookAroundScene = try? await request.scene
        }
    }
}

