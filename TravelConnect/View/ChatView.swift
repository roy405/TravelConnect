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
                        selectedImage: .constant(nil), // Or some binding to a UIImage?
                        showImagePicker: .constant(false), // Or some binding to a Bool?
                        viewModel: viewModel,
                        conversation: conversation
                    )
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

struct ShareModalView: View {
    @Binding var selectedImage: UIImage?
    @Binding var showImagePicker: Bool
    var viewModel: ConversationsViewModel
    var conversation: Conversation

    var body: some View {
        VStack {
            Button("Pick Image") {
                showImagePicker.toggle()
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage, isShown: $showImagePicker)
            }
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 200, height: 200)
                    .padding()

                Button("Send Image") {
                    viewModel.uploadMediaToFirebase(image: image) { urlString in
                        guard let urlString = urlString else {
                            print("Failed to upload media.")
                            return
                        }
                        // Now send the message with the media URL
                        viewModel.sendMessage(conversation: conversation, text: nil, mediaURL: urlString, senderID: Auth.auth().currentUser?.uid ?? "")
                    }
                }
            }
        }
    }
}

struct MessageView: View {
    var message: Message
    var currentUserID: String

    var body: some View {
        if let mediaURL = message.mediaURL, let url = URL(string: mediaURL) {
            WebImage(url: url)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .cornerRadius(15)
                .padding()

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
            VStack(alignment: .center, spacing: 20) {
                // Conversation Icon and Name
                VStack {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding()
                    Text(chatName)
                        .font(.headline)
                        .padding()
                }

                // Photos
                SectionView(title: "Photos", content: {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.messages, id: \.id) { message in
                                if let mediaURL = message.mediaURL, let url = URL(string: mediaURL) {
                                    WebImage(url: url)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(15)
                                        .padding()
                                }
                            }
                        }
                    }
                })

                // Collaboration
                SectionView(title: "Collaboration", content: {
                    HStack {
                        Image(systemName: "person.2") // Placeholder for collaboration icon
                        Text("Collaboration details here") // Placeholder text
                    }
                })

                // Routes
                SectionView(title: "Routes", content: {
                    HStack {
                        Image(systemName: "map") // Placeholder for route icon
                        Text("Route details here") // Placeholder text
                    }
                })

                // Notes
                SectionView(title: "Notes", content: {
                    HStack {
                        Image(systemName: "note.text") // Placeholder for note icon
                        Text("Notes details here") // Placeholder text
                    }
                })

                // Shared Files
                SectionView(title: "Shared Files", content: {
                    HStack {
                        Image(systemName: "doc") // Placeholder for file icon
                        Text("Shared file details here") // Placeholder text
                    }
                })

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
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}




