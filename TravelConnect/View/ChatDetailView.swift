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
    @ObservedObject var viewModel: ConversationsViewModel
    // State for editable chat name to allow renaming of the chat
    @State private var editableChatName: String
    // State for a mutable version of the conversation for any updates made within the view
    @State private var mutableConversation: Conversation
    
    // Initializer to setup initial values and inject necessary dependencies
    init(conversation: Conversation, viewModel: ConversationsViewModel) {
        self.viewModel = viewModel
        // Setting initial value for the editable chat name
        self._editableChatName = State(initialValue: conversation.displayName)
        // Setting initial value for the mutable conversation
        self._mutableConversation = State(initialValue: conversation)
    }
    
    // The main body of the ChatDetailView
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
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
                if mutableConversation.isGroup {
                    // Allow editing the chat name
                    SectionView(title: "Chat Name") {
                        HStack {
                            TextField("Chat Name", text: $editableChatName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button(action: {
                                viewModel.updateConversationName(conversation: mutableConversation, newName: editableChatName) { result in
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
                }
                
                // Display photos related to the chat/trip
                SectionView(title: "Photos") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.messages, id: \.id) { message in
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
                
                // Display Collaborations related to chat/trip
                SectionView(title: "Collaboration") {
                    HStack(spacing: 10) {
                        Image(systemName: "person.2")
                            .frame(width: 25, height: 25)
                        Text("Collaboration details here")
                    }
                }
                
                // Published Routes related to chat/trip
                SectionView(title: "Routes") {
                    HStack(spacing: 10) {
                        Image(systemName: "map")
                            .frame(width: 25, height: 25)
                        Text("Route details here")
                    }
                }
                
                // Notes Related to chat/trip
                SectionView(title: "Notes") {
                    HStack(spacing: 10) {
                        Image(systemName: "note.text")
                            .frame(width: 25, height: 25)
                        Text("Notes details here")
                    }
                }
                
                // Shared Files Related to chat/trip
                SectionView(title: "Shared Files") {
                    HStack(spacing: 10) {
                        Image(systemName: "doc")
                            .frame(width: 25, height: 25)
                        Text("Shared file details here")
                    }
                }
                
                Spacer()
            }
            .padding()
        }
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
