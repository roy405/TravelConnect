//
//  NewConversationView.swift
//  TravelConnect
//
//  Created by Cube on 10/27/23.
//

import SwiftUI

struct Email: Identifiable {
    var id = UUID()
    var value: String
}

struct NewConversationView: View {
    @Binding var showModal: Bool
    @ObservedObject var viewModel: ConversationsViewModel
    @State private var emails: [Email] = []
    
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        
        NavigationView {
            VStack(spacing: 15) {
                List {
                    ForEach(emails) { email in
                        HStack {
                            TextField("Enter email", text: Binding(
                                get: { email.value },
                                set: { newValue in
                                    if let index = emails.firstIndex(where: { $0.id == email.id }) {
                                        emails[index].value = newValue
                                    }
                                }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: {
                                withAnimation {
                                    self.deleteEmail(email: email)
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                // Buttons vertically aligned
                VStack(spacing: 15) {
                    Button("Add Another Email") {
                        withAnimation {
                            emails.append(Email(value: ""))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Create Conversation") {
                        let lowercasedEmails = emails.map { $0.value.lowercased() }
                        viewModel.startNewConversation(with: lowercasedEmails, isGroup: true) { result in
                            switch result {
                            case .success:
                                showModal = false
                            case .failure(let error):
                                alertMessage = error.localizedDescription
                                showAlert = true
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }

            }
            .padding()
            .navigationBarTitle("New Conversation", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showModal = false
                    }
                }
            }
        }
    }
    
    private func deleteEmail(email: Email) {
        emails.removeAll(where: { $0.id == email.id })
    }
}




