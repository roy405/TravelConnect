//
//  ConversationSelectionView.swift
//  TravelConnect
//
//  Created by Cube on 10/31/23.
//

import SwiftUI

struct ConversationSelectionView: View {
    @EnvironmentObject var conversationViewModel: ConversationsViewModel
    @Binding var selectedConversation: Conversation?
    var currentUserEmail: String?

    var body: some View {
        List(conversationViewModel.conversations, id: \.id) { conversation in
            Button(action: {
                self.selectedConversation = conversation
            }) {
                Text(conversation.displayName)
            }
        }
        .foregroundColor(Color(red: 0.0196, green: 0.2941, blue: 0.2863))
        .onAppear {
            if let email = currentUserEmail {
                conversationViewModel.fetchConversations(email: email)
            }
        }
    }
}



