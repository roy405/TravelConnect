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
    
    // Assuming the current user's ID is fetched and stored in currentUserID in the ConversationsViewModel
    var currentUserID: String {
        viewModel.currentUserID
    }

    var body: some View {
        VStack(spacing: 10) {
            List(viewModel.messages) { message in
                HStack {
                    if message.senderID == currentUserID {
                        Spacer()  // Pushes the content to the right side
                        Text(message.text)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(15)
                    } else {
                        Text(message.text)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(15)
                        Spacer()  // Pushes the content to the left side
                    }
                }
            }
            .padding(.bottom, 10)

            HStack {
                TextField("Enter message", text: $messageText)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)

                Button("Send") {
                    viewModel.sendMessage(conversation: conversation, text: messageText, senderID: Auth.auth().currentUser?.uid ?? "")
                    messageText = ""
                }
                .padding()
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

