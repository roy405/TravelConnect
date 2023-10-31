//
//  ConversationListView.swift
//  TravelConnect
//
//  Created by Cube on 10/26/23.
//

import SwiftUI

struct ErrorAlert: Identifiable {
    let id = UUID()
    var message: String
}

// View that displays a list of user conversations.
struct ConversationsListView: View {
    // View model responsible for fetching and managing conversation-related data.
    @EnvironmentObject var conversationViewModel: ConversationsViewModel
    // State variable to hold the currently selected conversation.
    @State private var selectedConversation: Conversation?
    // State variable to control the visibility of the action sheet.
    @State private var showActionSheet = false
    // State variable to control the visibility of the modal to create a new conversation.
    @State private var showCreateConversationModal = false
    // Error alert state variable
    @State private var errorAlert: ErrorAlert?
    // Environemnt Object for Trip View Model
    @EnvironmentObject var tripDetailViewModel: TripDetailViewModel
    @EnvironmentObject var mapViewModel: MapViewModel
    
    var body: some View {
        List(conversationViewModel.conversations) { conversation in
            NavigationLink(destination: ChatView(conversation: conversation)
                .environmentObject(tripDetailViewModel)
                .environmentObject(mapViewModel)
                .environmentObject(conversationViewModel)
            ) {
                HStack(spacing: 15) {
                    // Display a circle avatar with the initial of the conversation display name.
                    Circle()
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color(red: 0.0196, green: 0.2941, blue: 0.2863))
                        .overlay(
                            Text(conversation.displayName.prefix(1))
                                .foregroundColor(.white)
                                .font(.headline)
                        )
                    // Display the full conversation name.
                    Text(conversation.displayName)
                        .font(.headline)
                        .padding(.vertical)
                    
                }
                .background(
                    // Handle tap actions on the conversation.
                    Rectangle().fill(Color.clear)
                        .onTapGesture {
                            self.selectedConversation = conversation
                            if conversation.memberEmails.count > 2 {
                                self.showActionSheet = true
                            }
                        }
                )
            }
            //            Divider() // Separate each conversation with a divider.
        }
        .listStyle(.plain)
        .onAppear { // Fetch conversations when the view appears.
            if let user = conversationViewModel.authViewModel.currentUserEmail {
                print(user)
                conversationViewModel.fetchConversations(email: user)
            }
        }
        // Define the action sheet for conversation options.
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(title: Text("Options"), buttons: [
                .default(Text("Rename Conversation")) {
                    // Provide UI to rename
                },
                .default(Text("Convert to Group")) {
                    if let conversation = self.selectedConversation {
                        conversationViewModel.convertToGroup(conversation: conversation) { result in
                            switch result {
                            case .success():
                                print("Successfully converted to group.")
                            case .failure(let error):
                                errorAlert = ErrorAlert(message: error.localizedDescription)
                            }
                        }
                    }
                },
                .cancel()
            ])
        }
        .alert(item: $errorAlert) { alert in
            Alert(title: Text("Error"),
                  message: Text(alert.message),
                  dismissButton: .default(Text("OK")))
        }
        // Define the navigation bar appearance and items.
        .navigationBarTitle("Conversations")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
                                Button(action: {
            self.showCreateConversationModal = true
        }) {
            Image(systemName: "plus")
        }
            .sheet(isPresented: $showCreateConversationModal) {
                NewConversationView(showModal: $showCreateConversationModal, viewModel: conversationViewModel)
            }
        )
    }
}

