//
//  ConversationListView.swift
//  TravelConnect
//
//  Created by Cube on 10/26/23.
//

import SwiftUI

struct ConversationsListView: View {
    @ObservedObject var viewModel: ConversationsViewModel
    @State private var selectedConversation: Conversation?
    @State private var showActionSheet = false
    @State private var showCreateConversationModal = false

    var body: some View {
        List(viewModel.conversations) { conversation in
            NavigationLink(destination: ChatView(viewModel: viewModel, conversation: conversation)) {
                HStack(spacing: 15) {
                    // Circle avatar for each conversation
                    Circle()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                        .overlay(
                            Text(conversation.displayName.prefix(1))
                                .foregroundColor(.white)
                                .font(.headline)
                        )

                    Text(conversation.displayName)
                        .font(.headline)
                        .padding(.vertical)

                }
                .background(
                    Rectangle().fill(Color.clear)
                    .onTapGesture {
                        self.selectedConversation = conversation
                        if conversation.memberEmails.count > 2 {
                            self.showActionSheet = true
                        }
                    }
                )
            }
            Divider()
        }

        .onAppear {  // Place it here, on the List
            if let user = viewModel.authViewModel.currentUserEmail {
                print(user)
                viewModel.fetchConversations(email: user)
            }
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(title: Text("Options"), buttons: [
                .default(Text("Rename Conversation")) {
                    // Provide UI to rename
                },
                .default(Text("Convert to Group")) {
                    if let conversation = self.selectedConversation {
                        viewModel.convertToGroup(conversation: conversation)
                    }
                },
                .cancel()
            ])
        }
        .navigationBarTitle("Conversations")
        .navigationBarItems(trailing:
            Button(action: {
                self.showCreateConversationModal = true
            }) {
                Image(systemName: "plus")
            }
            
            .sheet(isPresented: $showCreateConversationModal) {
                NewConversationView(showModal: $showCreateConversationModal, viewModel: viewModel)
            }
        )
    }
}

