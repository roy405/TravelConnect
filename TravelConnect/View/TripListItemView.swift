//
//  TripListItemView.swift
//  TravelConnect
//
//  Created by Yangru Guo on 29/10/2023.
//

import SwiftUI
import CoreData

struct TripListItemView: View {
    @State var trip:Trip?
    @EnvironmentObject var tripDetailViewModel:TripDetailViewModel
    @Environment(\.managedObjectContext) private var context
    var body: some View {
        ZStack{
            Image(uiImage:(UIImage(data:trip?.topImage ?? Data()) ?? UIImage(named:"rivertest")!))
                .resizable()
                .frame(height:220)
                .cornerRadius(10)
            VStack{
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 100)
                ZStack{
                    Rectangle()
                        .fill(.white)
                    VStack(alignment:.leading){
                        HStack{
                            Text(trip?.type ?? "Title")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Text(trip?.dateString ?? "Time")
                                .foregroundColor(.black)
                        }
                        Text(trip?.tripInfo ?? "TripInfo")
                            .multilineTextAlignment(.leading)
                            .font(.body)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding()
                }
                .frame(height: 120)
            }
            
        }
        .cornerRadius(10)
        .frame(height:220)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    TripListItemView()
}
