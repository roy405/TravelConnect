//
//  NewConversationView.swift
//  TravelConnect
//
//  Created by Cube on 10/27/23.
//

import SwiftUI

// Represents an email data structure.
struct Email: Identifiable {
    var id = UUID()   // Unique identifier for each email.
    var value: String // Email value.
}

// A SwiftUI view to start a new conversation.
struct NewConversationView: View {
    @Binding var showModal: Bool    // Binding to control the visibility of the modal.
    @ObservedObject var viewModel: ConversationsViewModel // ViewModel to handle conversations-related operations.
    @State private var emails: [Email] = []  // Array to store email entries.
    
    @State private var showAlert = false    // State to control the visibility of an alert.
    @State private var alertMessage = ""    // Message to be displayed in the alert.
    
    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                
                // List to display all email entries.
                List {
                    ForEach(emails) { email in
                        HStack {
                            // Editable text field for email.
                            TextField(" Enter email", text: Binding(
                                get: { email.value },
                                set: { newValue in
                                    // Update the value of the email.
                                    if let index = emails.firstIndex(where: { $0.id == email.id }) {
                                        emails[index].value = newValue
                                    }
                                }
                            ))
                            .frame(height:50)
                            .background(RoundedRectangle(cornerRadius: 15).strokeBorder(Color(.systemGray6), lineWidth: 1))
                            
                            // Button to delete the email entry.
                            Button(action: {
                                withAnimation {
                                    self.deleteEmail(email: email)
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .imageScale(.large)
                            }
                        }
                        .padding(.vertical,5)
                    }
                }
                
                // Buttons to add an email and to create a conversation.
                HStack{
                    Spacer()
                    // Button to add a new email entry.
                    Button("Add Email") {
                        withAnimation {
                            emails.append(Email(value: ""))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width:UIScreen.main.bounds.width * 0.45,height:50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Spacer()
                    // Button to initiate the creation of a new conversation.
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
                    .frame(width:UIScreen.main.bounds.width * 0.45,height:50)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    Spacer()
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                
            }
            .padding(.all,20)
            .navigationBarTitle("New Conversation", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Button to close the modal.
                    Button("Done") {
                        showModal = false
                    }
                }
            }
        }
    }
    
    // Function to delete an email from the list.
    private func deleteEmail(email: Email) {
        emails.removeAll(where: { $0.id == email.id })
    }
}





