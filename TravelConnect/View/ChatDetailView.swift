//
//  ChatDetailView.swift
//  TravelConnect
//
//  Created by Cube on 10/31/23.
//

import SwiftUI
import FirebaseAuth
import SDWebImageSwiftUI

// This view represents the detailed view of a single chat/conversation
struct ChatDetailView: View {
    // ViewModel to fetch and manage data related to conversations
    @EnvironmentObject var conversationViewModel: ConversationsViewModel
    // Viewmodel for all things trip
    @EnvironmentObject var tripDetailViewModel: TripDetailViewModel
    @EnvironmentObject var mapViewModel: MapViewModel
    // State for editable chat name to allow renaming of the chat
    @State private var editableChatName: String
    // State for a mutable version of the conversation for any updates made within the view
    @State private var mutableConversation: Conversation
    // Variable for showing the trip list
    @State private var showTripList: Bool = false
    
    
    // Initializer to setup initial values and inject necessary dependencies
    init(conversation: Conversation) {
        self._editableChatName = State(initialValue: conversation.displayName)
        self._mutableConversation = State(initialValue: conversation)
    }
    
    // The main body of the ChatDetailView
    var body: some View {
        NavigationView{
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    // Conversation Icon and Name
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text(mutableConversation.displayName)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.leading)
                    }
                    .padding(.vertical)
                    .padding(.leading,10)
                    if mutableConversation.isGroup {
                        // Allow editing the chat name
                        SectionView(title: "Chat Name") {
                            HStack {
                                TextField("Chat Name", text: $editableChatName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Button(action: {
                                    conversationViewModel.updateConversationName(conversation: mutableConversation, newName: editableChatName) { result in
                                        switch result {
                                        case .success():
                                            print("Chat renamed successfully.")
                                            mutableConversation.displayName = editableChatName
                                        case .failure(let error):
                                            print("Error updating chat name:", error)
                                        }
                                    }
                                }) {
                                    Text("Save")
                                }
                            }
                        }
                        .frame(width:UIScreen.main.bounds.width - 20)
                        .padding(.horizontal,10)
                    }
                    
                    Spacer()
                    
                    
                    
                    // Chat Detail button that is dynamic based on the status of a trip being linked to the chat.
                    if mutableConversation.tripID == nil {
                        Button(action: {
                            print("Link Trip Button Pressed")
                            // Toggle the list after fetching the trips.
                            self.showTripList.toggle()
                        }) {
                            Text("Link Trip")
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .sheet(isPresented: $showTripList) {
                            TripSelectListView(trips: $tripDetailViewModel.allTrips, selectedTrip: { trip in
                                // Handle the trip selection
                                self.mutableConversation.tripID = trip.id  // set the tripID
                                self.conversationViewModel.updateConversationWithTripIDUsingInternalID(internalID: mutableConversation.id, tripID: trip.id.uuidString) {  result in
                                    switch result {
                                    case .success():
                                        print("Conversation updated successfully with TripID.")
                                    case .failure(let error):
                                        print("Error updating conversation with TripID:", error)
                                    }
                                }
                                
                                // Here, update your CoreData Trip entity to have the conversation ID
                                tripDetailViewModel.updateTripWithConversationID(tripID: trip.id, conversationID: mutableConversation.id, context: PersistenceController.shared.container.viewContext)
                                // Save the trip changes to CoreData
                                
                                self.showTripList.toggle()  // dismiss the sheet after linking
                            })
                        }
                    } else {
                        if let linkedTrip = tripDetailViewModel.allTrips.first(where: { $0.id == mutableConversation.tripID }) {
                            Text(linkedTrip.type) // Display the type of the linked trip
                                .font(.headline)
                                .padding()
                            NavigationLink(destination: TripDetailView(trip: linkedTrip, isEditingMode: false)
                                .environmentObject(mapViewModel)
                                .environmentObject(tripDetailViewModel)) {
                                    Text("View Trip Details")
                                        .frame(maxWidth: .infinity, minHeight: 44)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .padding(.bottom)
                        }
                    }
                    
                    
                    // Display photos related to the chat/trip
                    SectionView(title: "Photos") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(conversationViewModel.messages, id: \.id) { message in
                                    if let mediaURL = message.mediaURL, let url = URL(string: mediaURL) {
                                        WebImage(url: url)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 120, height: 120)
                                            .cornerRadius(15)
                                            .padding(.trailing, 15)
                                    }
                                }
                            }
                        }
                    }
                    .frame(width:UIScreen.main.bounds.width - 20)
                    .padding(.horizontal,10)
                    // Display Collaborations related to chat/trip
                    SectionView(title: "Collaboration") {
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(spacing: 10) {
                                Image(systemName: "person.2")
                                    .imageScale(.large)
                                Text("Collaboration details here")
                            }
                        }
                    }
                    .frame(width:UIScreen.main.bounds.width - 20)
                    .padding(.horizontal,10)
                    // Published Routes related to chat/trip
                    SectionView(title: "Routes") {
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(spacing: 10) {
                                Image(systemName: "map")
                                    .imageScale(.large)
                                Text("Route details here")
                            }
                        }
                    }
                    .frame(width:UIScreen.main.bounds.width - 20)
                    .padding(.horizontal,10)
                    // Notes Related to chat/trip
                    SectionView(title: "Notes") {
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(spacing: 10) {
                                Image(systemName: "note.text")
                                    .imageScale(.large)
                                Text("Notes details here")
                            }
                        }
                    }
                    .frame(width:UIScreen.main.bounds.width - 20)
                    .padding(.horizontal,10)
                    // Shared Files Related to chat/trip
                    SectionView(title: "Shared Files") {
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack(spacing: 10) {
                                Image(systemName: "doc")
                                    .imageScale(.large)
                                Text("Shared file details here")
                            }
                        }
                    }
                    .frame(width:UIScreen.main.bounds.width - 20)
                    .padding(.horizontal,10)
                    Spacer()
                }
                .padding()
            }
            .onAppear {
                tripDetailViewModel.fetchAllTrips(context: PersistenceController.shared.container.viewContext)
                for trip in tripDetailViewModel.allTrips {
                    print("Trip ID:", trip.id.uuidString)
                }
            }}
    }
}

// Generic SectionView
struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 10)
            content
        }
        .padding()
        .background(Color(UIColor.systemGray5))
        .cornerRadius(10)
        .padding(.bottom, 15)
    }
}
