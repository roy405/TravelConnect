//
//  SwiftUIView.swift
//  TravelConnect
//
//  Created by Yangru Guo on 28/10/2023.
//

import SwiftUI

struct PlaceOfInterestView: View {
    @EnvironmentObject var tripDetailViewModel:TripDetailViewModel
    @State var pointOfInterest:PlaceOfInterest?
    @State var time:Date = Date()
    @State var type:String = "Dining"
    @State var image:String = "fork.knife.circle"
    @State var title:String = "Place Of Interest"
    @State var description:String = "Description of the point of interest goes here.Description of the point of interest goes here.Description of the point of interest goes here.Description of the point of interest goes here."
    private var dateString:String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        let formattedDate = dateFormatter.string(from: time)
        return formattedDate
    }
    private var timeString:String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:MM"
        let formattedDate = dateFormatter.string(from: time)
        return formattedDate
    }
    var screenHeight:CGFloat = UIScreen.main.bounds.height
    var screenWidth:CGFloat = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationLink(value: pointOfInterest){
            ZStack{
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.indigo.opacity(0.05))
                    .shadow(radius: 2)
                    .frame(height: 120)
                HStack {
                    VStack(alignment: .trailing, spacing: 5) {
                        Text(dateString)
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.primary)
                        Text(timeString)
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .frame(width: screenWidth * 0.2)
                    
                    VStack {
                        Image(systemName: image)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(tripDetailViewModel.getColorForActivity(pointOfInterest!.type))
                        Spacer()
                    }
                    .frame(width: screenWidth * 0.15)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(title)
                            .font(.title3)
                            .bold()
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        ScrollView {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .frame(width: screenWidth * 0.5)
                    Spacer()
                }
                .frame(width: screenWidth - 20, height: 100)
            }
            .padding(.horizontal,10)
            .padding(.top,5)
            .onAppear{
                time = pointOfInterest?.time ?? Date()
                type = pointOfInterest?.type ?? "Dining"
                title = pointOfInterest?.name ?? "Place of Interest"
                description = pointOfInterest?.description ?? "Description of the point of interest goes here.Description of the point of interest goes here.Description of the point of interest goes here.Description of the point of interest goes here."
                if let type = pointOfInterest?.type {
                    image = tripDetailViewModel.getImageIconName(type: pointOfInterest!.type)
                }
            }
        }
    }
}

#Preview {
    PlaceOfInterestView()
}
