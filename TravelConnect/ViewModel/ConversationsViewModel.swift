//
//  ConversationsViewModel.swift
//  TravelConnect
//
//  Created by Cube on 10/26/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ConversationsViewModel: ObservableObject {
    @Published var conversations = [Conversation]()
    @Published var messages: [Message] = []
    @Published var currentUserID: String = ""
    
    var authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        self.fetchCurrentUserID(email: authViewModel.currentUserEmail ?? "")
        print("ezman2 : \(currentUserID)")
    }
    
    private var db = Firestore.firestore()
    
    // Fetches conversations of a user
    func fetchConversations(email: String) {
        print("email : \(email)")
        
        db.collection("conversations").whereField("memberEmails", arrayContains: email).addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error fetching conversations: \(error.localizedDescription)")
                return
            }
            guard let documents = querySnapshot?.documents else {
                print("No conversations found.")
                return
            }
            
            print("Number of conversations fetched: \(documents.count)")
            
            var fetchedConversations: [Conversation] = []
            
            let group = DispatchGroup()
            
            documents.forEach { queryDocumentSnapshot in
                group.enter()
                
                guard let conversation = Conversation(documentID: queryDocumentSnapshot.documentID, documentData: queryDocumentSnapshot.data()) else {
                    group.leave()
                    return
                }
                print("Successfully created conversation object: \(conversation)")
                
                self.updateConversationDisplayName(conversation: conversation) { updatedConversation in
                    fetchedConversations.append(updatedConversation)
                    print("Updated conversation added: \(updatedConversation)")
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.conversations = fetchedConversations
                print("All conversations processed. Total: \(fetchedConversations.count)")
            }
        }
    }
    
    
    
    // Fetches messages of a conversation
    func fetchMessages(conversationCustomID: String) {
        print("Inside fetchMessages function.")
        
        // First, find the document with the matching custom 'id'
        db.collection("conversations").whereField("id", isEqualTo: conversationCustomID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error finding matching conversation: \(error.localizedDescription)")
                return
            }
            
            // If found, get the Firestore document ID
            guard let document = querySnapshot?.documents.first else {
                print("No matching conversation found.")
                return
            }
            
            let firestoreDocumentID = document.documentID
            
            // Then fetch its messages using the Firestore document ID
            self.db.collection("conversations").document(firestoreDocumentID).collection("messages").order(by: "timestamp", descending: false).addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }
                
                guard let messages = querySnapshot?.documents else {
                    print("No messages found.")
                    return
                }
                
                self.messages = messages.compactMap({ queryDocumentSnapshot -> Message? in
                    var data = queryDocumentSnapshot.data() as [String: Any]
                    print("Received message data: \(data)")
                    data["id"] = queryDocumentSnapshot.documentID  // Add this line to insert the document ID into the data
                    return Message(documentData: data)
                })
                
            }
        }
    }
    
    
    // Sends a message
    func sendMessage(conversation: Conversation, text: String? = nil, mediaURL: String? = nil, senderID: String) {
        guard (text != nil && !(text?.isEmpty ?? true)) || mediaURL != nil else {
            print("Cannot send an empty message or without media URL.")
            return
        }

        print("About to send message to:", conversation.documentID)
        
        let message = Message(id: "", conversationID: conversation.documentID, senderID: senderID, text: text, timestamp: Date(), mediaURL: mediaURL)
        let messageData = message.toDictionary()
        
        db.collection("conversations").document(conversation.documentID).collection("messages").addDocument(data: messageData) { error in
            if let error = error {
                print("There was an error: \(error)")
            }
        }
    }
    
    // Function to start a new conversation
    func startNewConversation(with emails: [String], isGroup: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUserEmail = authViewModel.currentUserEmail else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Current user email not found"])))
            return
        }
        let allMemberEmails = emails + [currentUserEmail]

        // Check if the email exists in the Firestore users collection
        let group = DispatchGroup()
        var emailsNotFound: [String] = []

        for email in emails {
            group.enter()
            db.collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
                if querySnapshot?.documents.isEmpty ?? true {
                    emailsNotFound.append(email)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if !emailsNotFound.isEmpty {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot create conversation. Following users not found: \(emailsNotFound.joined(separator: ", ")) you may invite them to the app. :)"])))
                return
            }

            // Check if a conversation already exists with these emails
            self.db.collection("conversations").whereField("memberEmails", arrayContains: currentUserEmail).getDocuments { (querySnapshot, error) in
                if let conversations = querySnapshot?.documents {
                    for conversationDoc in conversations {
                        if let memberEmails = conversationDoc.data()["memberEmails"] as? [String], Set(memberEmails) == Set(allMemberEmails) {
                            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "A conversation/group already exists with these members."])))
                            return
                        }
                    }
                }

                // If all checks pass, proceed to create the new conversation
                var conversation = Conversation(memberEmails: allMemberEmails, currentUserEmail: currentUserEmail, displayName: "Default Group")
                
                let newConversationRef = self.db.collection("conversations").document() // create a reference to a new document
                newConversationRef.setData(conversation.toDictionary()) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        conversation.documentID = newConversationRef.documentID
                        let newMessage = Message(id: "", conversationID: newConversationRef.documentID, senderID: "", text: "Conversation initiated", timestamp: Date())
                        newConversationRef.collection("messages").addDocument(data: newMessage.toDictionary()) { error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                completion(.success(()))
                            }
                        }
                    }
                }
            }
        }
    }


    
    func fetchCurrentUserID(email: String) {
        print("this is the email we are getting \(email)")
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error finding user: \(error.localizedDescription)")
                return
            }
            
            guard let userDocument = querySnapshot?.documents.first, let userID = userDocument.data()["id"] as? String else {
                print("User not found.")
                return
            }
            
            self.currentUserID = userID
            print("THIS IS ID \(self.currentUserID)")
        }
    }
    
    func fetchUserName(for email: String, completion: @escaping (String?) -> Void) {
        print("Fetching user name for email: \(email)")
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error finding user: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let userDocument = querySnapshot?.documents.first,
                  let firstName = userDocument.data()["firstName"] as? String,
                  let lastName = userDocument.data()["lastName"] as? String else {
                print("User or user's names not found for email: \(email)")
                completion(nil)
                return
            }
            
            let fullName = "\(firstName) \(lastName)"
            print("Found user name: \(fullName) for email: \(email)")
            completion(fullName)
        }
    }
    
    func doesConversationExist(with emails: [String], completion: @escaping (Bool) -> Void) {
        db.collection("conversations").whereField("memberEmails", arrayContains: authViewModel.currentUserEmail ?? "").getDocuments { querySnapshot, error in
            if let error = error {
                print("Error checking conversation existence: \(error.localizedDescription)")
                completion(false)
                return
            }

            let existingConversations = querySnapshot?.documents.compactMap({ Conversation(documentID: $0.documentID, documentData: $0.data()) }) ?? []
            let isExisting = existingConversations.contains { conversation in
                Set(conversation.memberEmails) == Set(emails)
            }
            completion(isExisting)
        }
    }
    
    func doesEmailExist(email: String, completion: @escaping (Bool) -> Void) {
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { querySnapshot, error in
            if let error = error {
                print("Error checking email existence: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(!(querySnapshot?.documents.isEmpty ?? true))
        }
    }
    
    func uploadMediaToFirebase(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let data = image.jpegData(compressionQuality: 0.6) else {
            completion(nil)
            return
        }
        
        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("chat_images/\(imageName).jpeg")
        
        storageRef.putData(data, metadata: nil) { (_, error) in
            if let error = error {
                print("Error uploading image: \(error)")
                completion(nil)
            } else {
                storageRef.downloadURL { (url, error) in
                    guard let mainImageUrl = url?.absoluteString else {
                        
                        completion(nil)
                        return
                    }
                    print("Main Image URL: \(mainImageUrl)")

                    // Generate and upload the thumbnail
                    if let thumbnail = self.generateThumbnail(of: image, for: CGSize(width: 100, height: 100)),
                       let thumbnailData = thumbnail.jpegData(compressionQuality: 0.6) {
                        
                        let thumbnailRef = Storage.storage().reference().child("chat_images/\(imageName)_thumbnail.jpeg")
                        thumbnailRef.putData(thumbnailData, metadata: nil) { (_, error) in
                            if let error = error {
                                print("Error uploading thumbnail: \(error)")
                            }
                            // Continue with the main image URL, regardless of thumbnail upload success/failure
                            completion(mainImageUrl)
                        }
                    } else {
                        completion(mainImageUrl)
                    }
                }
            }
        }
    }

    
    func generateThumbnail(of image: UIImage, for size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    
    func updateConversationDisplayName(conversation: Conversation, completion: @escaping (Conversation) -> Void) {
        print("Updating display name for conversation: \(conversation)")
        var updatedConversation = conversation
        let emails = conversation.memberEmails

        // If it's a 2-person chat
        if emails.count == 2 {
            for email in emails {
                if email != authViewModel.currentUserEmail {  // Ensure it's not the current user
                    fetchUserName(for: email) { name in
                        guard let name = name else {
                            print("Name not found for email: \(email)")
                            return
                        }
                        updatedConversation.displayName = name
                        completion(updatedConversation)
                    }
                    break
                }
            }
        } else if emails.count > 2 {
            var names: [String] = []

            let group = DispatchGroup()
            for email in emails {
                if email != authViewModel.currentUserEmail {
                    group.enter()
                    fetchUserName(for: email) { name in
                        if let name = name {
                            names.append(name.components(separatedBy: " ")[0])  // Add only the first name
                        } else {
                            print("Name not found for email: \(email)")
                        }
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                if updatedConversation.displayName == "Default Group" || updatedConversation.displayName.isEmpty {
                    updatedConversation.displayName = names.joined(separator: ", ")
                }
                completion(updatedConversation)
            }
        } else {
            print("Email count not matched. Returning without modifications.")
            completion(updatedConversation)
        }
    }
}


extension ConversationsViewModel {
    
    // Change the name of a conversation (especially useful for groups)
    func updateConversationName(conversation: Conversation, newName: String) {
        db.collection("conversations").document(conversation.id).updateData([
            "displayName": newName
        ]) { error in
            if let error = error {
                print("Error updating name: \(error)")
            } else {
                print("Name successfully updated!")
            }
        }
    }
    
    // Convert a conversation to a group
    func convertToGroup(conversation: Conversation) {
        db.collection("conversations").document(conversation.id).updateData([
            "isGroup": true
        ]) { error in
            if let error = error {
                print("Error converting to group: \(error)")
            } else {
                print("Successfully converted to group!")
            }
        }
    }
}
