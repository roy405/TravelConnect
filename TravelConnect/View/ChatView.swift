//
//  ChatView.swift
//  TravelConnect
//
//  Created by Cube on 10/26/23.
//

import SwiftUI
import FirebaseAuth

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
            NavigationLink(destination: ChatDetailView(chatName: conversation.displayName)) {
                Text(conversation.displayName)
                    .font(.title2)
                    .padding(.vertical, 8)
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            List(viewModel.messages) { message in
                HStack {
                    if message.senderID == currentUserID {
                        Spacer()
                        Text(message.text)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(15)
                    } else {
                        Text(message.text)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(15)
                        Spacer()
                    }
                }
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
                    ShareModalView()
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
    var body: some View {
        VStack {
            // This is where you can design the options for your share modal
            Text("Share Options Go Here")
        }
    }
}

struct ChatDetailView: View {
    var chatName: String
    
    var body: some View {
        // Placeholder for the chat details view
        Text("Details for \(chatName)")
    }
}



