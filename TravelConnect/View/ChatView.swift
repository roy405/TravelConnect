//
//  ChatView.swift
//  TravelConnect
//
//  Created by Cube on 10/26/23.
//

import SwiftUI
import FirebaseAuth
import SDWebImageSwiftUI

struct ChatView: View {
    // Observable object to fetch and handle conversation data and for trip information.
    @EnvironmentObject var conversationViewModel: ConversationsViewModel
    @EnvironmentObject var tripDetailViewModel: TripDetailViewModel
    @EnvironmentObject var mapViewModel: MapViewModel
    // Current chat conversation.
    var conversation: Conversation
    
    // State properties for UI interactions.
    @State private var messageText: String = ""
    @State private var showShareModal: Bool = false
    @State private var navigateToShareModal: Bool = false
    @State private var selectedImage: UIImage? = nil
    @State private var navigationTrigger: Int? = nil
    @State private var showImagePickerFromModal: Bool = false
    
    @State private var showChatDetailView:Bool = false
    
    // Property to get current user's ID.
    var currentUserID: String {
        conversationViewModel.currentUserID
    }
    
    
    var body: some View {
        NavigationView{
            VStack(spacing: 1) {
//                // Navigation link to detailed chat view.
//                NavigationLink(destination: ChatDetailView(conversation: conversation, viewModel: viewModel)) {
//                    Text(conversation.displayName)
//                        .font(.title2)
//                        .padding(.vertical, 8)
//                }
//                .background(Color.gray.opacity(0.1))
//                .cornerRadius(10)
                // Display all the messages in the chat.
                List(conversationViewModel.messages, id: \.id) { message in
                    MessageView(message: message, currentUserID: currentUserID)
                }
                .padding(.bottom, 10)
                
                HStack(spacing: 10) {
                    // Button to display a modal to share content.
                    Button(action: {
                        showShareModal.toggle()
                    }) {
                        Image(systemName: "plus")
                            .frame(width: 36, height: 36)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(18)
                    }
                    .sheet(isPresented: $showShareModal) {
                        ShareModalView(
                            selectedImage: $selectedImage,
                            showImagePicker: $showImagePickerFromModal,
                            viewModel: conversationViewModel,
                            conversation: conversation
                        )
                    }
                    
                    .onTapGesture {
                        navigateToShareModal.toggle()
                    }
                    // Text field to input a new message.
                    TextField("Enter message", text: $messageText)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                        .layoutPriority(1)
                    
                    Button("Send") {
                        conversationViewModel.sendMessage(conversation: conversation, text: messageText, senderID: Auth.auth().currentUser?.uid ?? "")
                        messageText = ""
                    }
                    .frame(minWidth: 50)
                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing ) {
                Button(action: {
                    showChatDetailView = true
                }) {
                    HStack{
                        Text(conversation.displayName)
                            .bold()
                        Image(systemName: "person.3")
                    }
                    .padding(.trailing)
                }
                .sheet(isPresented: $showChatDetailView) {
                    ChatDetailView(conversation: conversation)
                        .environmentObject(tripDetailViewModel)
                        .environmentObject(mapViewModel)
                        .environmentObject(conversationViewModel)
                }
            }
        }
        .onAppear {
            conversationViewModel.fetchMessages(conversationCustomID: conversation.id)
            print(1,conversationViewModel.messages)
        }
    }
}

// View representation of a single message.
struct MessageView: View {
    var message: Message
    var currentUserID: String
    
    var body: some View {
        // If message contains an image, display.
        if let mediaURL = message.mediaURL, let url = URL(string: mediaURL) {
            HStack {
                if message.senderID == currentUserID {
                    Spacer()
                }
                WebImage(url: url)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .cornerRadius(15)
                    .padding()
                if message.senderID != currentUserID {
                    Spacer()
                }
            }
        } else {
            // If message contains text, display.
            HStack {
                if message.senderID == currentUserID {
                    Spacer()
                    Text(message.text ?? "")
                        .padding()
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(15)
                } else {
                    Text(message.text ?? "")
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                    Spacer()
                }
            }
        }
    }
}







