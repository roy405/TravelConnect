//
//  NewConversationView.swift
//  TravelConnect
//
//  Created by Cube on 10/27/23.
//

import SwiftUI

struct NewConversationView: View {
    @Binding var showModal: Bool
    @ObservedObject var viewModel: ConversationsViewModel
    @State private var emails: [String] = []


    var body: some View {
        VStack {
            ForEach(emails.indices, id: \.self) { index in
                TextField("Enter email", text: $emails[index])
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }

            Button("Add Another Email") {
                emails.append("")
            }
            .padding()
            Button("Create Conversation") {
                let lowercasedEmails = emails.map { $0.lowercased() }
                viewModel.startNewConversation(with: lowercasedEmails, isGroup: true)
                showModal = false
            }
            .padding()
        }
    }
}

