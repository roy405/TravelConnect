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
    @ObservedObject var viewModel: ConversationsViewModel
    var conversation: Conversation

    @State private var messageText: String = ""
    @State private var showShareModal: Bool = false
    @State private var navigateToShareModal: Bool = false
    @State private var selectedImage: UIImage? = nil
    @State private var navigationTrigger: Int? = nil
    @State private var showImagePickerFromModal: Bool = false

    
    var currentUserID: String {
        viewModel.currentUserID
    }

    var body: some View {
        VStack(spacing: 1) {
            // Title for the chat
            NavigationLink(destination: ChatDetailView(chatName: conversation.displayName, viewModel: viewModel)) {
                Text(conversation.displayName)
                    .font(.title2)
                    .padding(.vertical, 8)
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            List(viewModel.messages, id: \.id) { message in
                MessageView(message: message, currentUserID: currentUserID)
            }
            .padding(.bottom, 10)

            HStack(spacing: 10) {
                // Button to bring up the share modal
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
                        viewModel: viewModel,
                        conversation: conversation
                    )
                }

                .onTapGesture {
                    navigateToShareModal.toggle()
                }
                
                TextField("Enter message", text: $messageText)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .layoutPriority(1)

                Button("Send") {
                    viewModel.sendMessage(conversation: conversation, text: messageText, senderID: Auth.auth().currentUser?.uid ?? "")
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
        .onAppear {
            print("Fetching messages for conversationID: \(conversation.id)")
            viewModel.fetchMessages(conversationCustomID: conversation.id)
        }
    }
}


struct MessageView: View {
    var message: Message
    var currentUserID: String

    var body: some View {
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





struct ChatDetailView: View {
    var chatName: String
    @ObservedObject var viewModel: ConversationsViewModel  // Inject the viewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Conversation Icon and Name
                HStack {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                    Text(chatName)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.leading)
                }
                .padding(.vertical)

                // Photos
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

                // Collaboration
                SectionView(title: "Collaboration") {
                    HStack(spacing: 10) {
                        Image(systemName: "person.2")
                            .frame(width: 25, height: 25)
                        Text("Collaboration details here")
                    }
                }

                // Routes
                SectionView(title: "Routes") {
                    HStack(spacing: 10) {
                        Image(systemName: "map")
                            .frame(width: 25, height: 25)
                        Text("Route details here")
                    }
                }

                // Notes
                SectionView(title: "Notes") {
                    HStack(spacing: 10) {
                        Image(systemName: "note.text")
                            .frame(width: 25, height: 25)
                        Text("Notes details here")
                    }
                }

                // Shared Files
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
        .background(Color(UIColor.systemGray5)) // Use a system background color
        .cornerRadius(10)
        .padding(.bottom, 15)
    }
}






