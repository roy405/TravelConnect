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

// The `ConversationsViewModel` class handles the logic related to conversations and messages.
class ConversationsViewModel: ObservableObject {
    // Observable properties
    @Published var conversations = [Conversation]()   // List of conversations for the user
    @Published var messages: [Message] = []           // List of messages in a selected conversation
    @Published var currentUserID: String = ""         // ID of the current user
    @Published var fetchError: Error?                 // Error state to relay to the view
    @Published var sendMessageError: Error?           // Error state to relay message error to the view
    var authViewModel: AuthViewModel
    
    // Initializer for the ViewModel
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        fetchCurrentUserID(email: authViewModel.currentUserEmail ?? "") { userID in }
    }
    
    // Firebase Firestore reference
    private var db = Firestore.firestore()
    
    // Fetches the conversations that the user is a part of.
    func fetchConversations(email: String) {
        db.collection("conversations").whereField("memberEmails", arrayContains: email).addSnapshotListener { querySnapshot, error in
            // Handle any errors in fetching conversations
            if let error = error {
                self.fetchError = error
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                self.fetchError = NSError(domain: "ConversationsViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "No conversations found."])
                return
            }
            
            var fetchedConversations: [Conversation] = []
            
            // Iterate through each conversation document and create a Conversation object
            for queryDocumentSnapshot in documents {
                guard let conversation = Conversation(documentID: queryDocumentSnapshot.documentID, documentData: queryDocumentSnapshot.data()) else {
                    self.fetchError = NSError(domain: "ConversationsViewModel", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to process conversation data."])
                    continue
                }
                fetchedConversations.append(conversation)
            }
            
            // Assign to the observable property
            self.conversations = fetchedConversations
        }
    }
    
    func fetchConversationByTrip(forTripID tripID: String, completion: @escaping (Conversation?) -> Void) {
        
        // Assuming you store conversations in a collection named "conversations"
        let db = Firestore.firestore()
        db.collection("conversations").whereField("tripID", isEqualTo: tripID).getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                completion(nil)
                return
            }
            // Here, I'm taking the first document, but you might want to handle it differently if there can be more than one
            let document = documents[0]
            let documentID = document.documentID
            let documentData = document.data()
            let conversation = Conversation(documentID: documentID, documentData: documentData)
            completion(conversation)
        }
    }
    
    func fetchConversationByID(forID id: String, completion: @escaping (Conversation?) -> Void) {
        // Assuming you store conversations in a collection named "conversations"
        let db = Firestore.firestore()
        db.collection("conversations").whereField("id", isEqualTo: id).getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                completion(nil)
                return
            }
            // Here, I'm taking the first document, but you might want to handle it differently if there can be more than one
            let document = documents[0]
            let documentID = document.documentID
            let documentData = document.data()
            let conversation = Conversation(documentID: documentID, documentData: documentData)
            completion(conversation)
        }
    }



    
    // Fetches messages of a conversation
    func fetchMessages(conversationCustomID: String) {
        
        var previousLength = messages.count
        // Finding  the document with the matching custom 'id'
        db.collection("conversations").whereField("id", isEqualTo: conversationCustomID).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.fetchError = error  // Update error state
                return
            }
            
            guard let document = querySnapshot?.documents.first else {
                self.fetchError = NSError(domain: "ConversationsViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "No matching conversation found."])  // Update error state
                return
            }
            
            let firestoreDocumentID = document.documentID
            
            // Fetch the messages associated with that conversation
            self.db.collection("conversations").document(firestoreDocumentID).collection("messages").order(by: "timestamp", descending: false).addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    self.fetchError = error  // Update error state
                    return
                }
                
                guard let messages = querySnapshot?.documents else {
                    self.fetchError = NSError(domain: "ConversationsViewModel", code: -2, userInfo: [NSLocalizedDescriptionKey: "No messages found."])  // Update error state
                    return
                }
                
                if messages.count > previousLength {
                    let content = UNMutableNotificationContent()
                    content.title = "New Message Alert"
                    content.body = "You got a new message! at \(Date())"
                    content.sound = UNNotificationSound.default
                    
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                    UNUserNotificationCenter.current().add(request)
                    print(previousLength,messages.count,"you got new")
                }
                // Map Firestore documents to Message objects
                self.messages = messages.compactMap({ queryDocumentSnapshot -> Message? in
                    var data = queryDocumentSnapshot.data() as [String: Any]
                    data["id"] = queryDocumentSnapshot.documentID
                    return Message(documentData: data)
                })
            }
        }
    }
    
    
    // Sends a message in a given conversation.
    func sendMessage(conversation: Conversation, text: String? = nil, mediaURL: String? = nil, senderID: String) {
        // Check for valid message content (text or media)
        guard (text != nil && !(text?.isEmpty ?? true)) || mediaURL != nil else {
            sendMessageError = NSError(domain: "ConversationsViewModel", code: -3, userInfo: [NSLocalizedDescriptionKey: "Cannot send an empty message or without media URL."])
            return
        }
        
        let message = Message(id: "", conversationID: conversation.documentID, senderID: senderID, text: text, timestamp: Date(), mediaURL: mediaURL)
        let messageData = message.toDictionary()
        
        // Add message to Firestore
        db.collection("conversations").document(conversation.documentID).collection("messages").addDocument(data: messageData) { error in
            if let error = error {
                print("There was an error: \(error)")
                self.sendMessageError = error  // Update error state
            }
        }
    }
    
    // Function to start a new conversation
    func startNewConversation(with emails: [String], isGroup: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUserEmail = authViewModel.currentUserEmail else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Current user email not found"])))
            return
        }
        guard emails.count > 0 else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Please add emails"])))
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
                
                self.updateConversationDisplayName(conversation: conversation) { updatedConversation in
                    conversation = updatedConversation

                    // Continue with the rest of the logic
                    let newConversationRef = self.db.collection("conversations").document()
                    newConversationRef.setData(conversation.toDictionary()) { error in
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
    
    // Fetches the user ID for a given email address.
    func fetchCurrentUserID(email: String, completion: @escaping (Result<String, Error>) -> Void) {
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if error != nil {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "An error occurred while fetching the user ID."])))
                return
            }
            
            guard let userDocument = querySnapshot?.documents.first, let userID = userDocument.data()["id"] as? String else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID not found for provided email."])))
                return
            }
            
            self.currentUserID = userID
            completion(.success(userID))
        }
    }
    
    // Fetches the full name for a given email address.
    func fetchUserName(for email: String, completion: @escaping (Result<String, Error>) -> Void) {
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if error != nil {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "An error occurred while fetching the user name."])))
                return
            }
            
            guard let userDocument = querySnapshot?.documents.first,
                  let firstName = userDocument.data()["firstName"] as? String,
                  let lastName = userDocument.data()["lastName"] as? String else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User's name not found for provided email."])))
                return
            }
            
            let fullName = "\(firstName) \(lastName)"
            completion(.success(fullName))
        }
    }
    // Function to update the current conversation with a trip id if decided to link to a trip
    func updateConversationWithTripIDUsingInternalID(internalID: String, tripID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Getting reference to the "conversations" collection
        let conversationsRef = db.collection("conversations")
        // Fetch conversations with matching internal ID
        conversationsRef.whereField("id", isEqualTo: internalID).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapshot = snapshot, !snapshot.documents.isEmpty else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No matching conversation found"])))
                return
            }
            let conversationDoc = snapshot.documents[0]
            // Update the tripID field of the fetched conversation
            conversationDoc.reference.updateData(["tripID": tripID]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }


    
    // Checks if a conversation already exists with the given member emails.
    func doesConversationExist(with emails: [String], completion: @escaping (Result<Bool, Error>) -> Void) {
        db.collection("conversations").whereField("memberEmails", arrayContains: authViewModel.currentUserEmail ?? "").getDocuments { querySnapshot, error in
            if error != nil {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "An error occurred while checking the conversation's existence."])))
                return
            }
            
            let existingConversations = querySnapshot?.documents.compactMap({ Conversation(documentID: $0.documentID, documentData: $0.data()) }) ?? []
            let isExisting = existingConversations.contains { conversation in
                Set(conversation.memberEmails) == Set(emails)
            }
            completion(.success(isExisting))
        }
    }
    
    // Function to check if a certain email exists in the users collection
    func doesEmailExist(email: String, completion: @escaping (Bool) -> Void) {
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { querySnapshot, error in
            if error != nil {
                completion(false)
                return
            }
            completion(!(querySnapshot?.documents.isEmpty ?? true))
        }
    }
    
    // Function to upload media to firebase storage for the chat functionality (Conversations/Trips)
    func uploadMediaToFirebase(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let data = image.jpegData(compressionQuality: 0.6) else {
            completion(nil)
            return
        }
        
        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("chat_images/\(imageName).jpeg")
        
        storageRef.putData(data, metadata: nil) { (_, error) in
            if error != nil {
                completion(nil)
            } else {
                storageRef.downloadURL { (url, error) in
                    guard let mainImageUrl = url?.absoluteString else {
                        completion(nil)
                        return
                    }
                    
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
    
    // Function to generate a thumbnail of the uploaded picture
    func generateThumbnail(of image: UIImage, for size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    // Function to update conversation display name based on number of people
    func updateConversationDisplayName(conversation: Conversation, completion: @escaping (Conversation) -> Void) {
        print("Updating display name for conversation: \(conversation)")
        var updatedConversation = conversation
        let emails = conversation.memberEmails
        
        // If it's a 2-person chat
        if emails.count == 2 {
            for email in emails {
                if email != authViewModel.currentUserEmail {  // Ensure it's not the current user
                    fetchUserName(for: email) { result in
                        switch result {
                        case .success(let name):
                            updatedConversation.displayName = name
                            completion(updatedConversation)
                        case .failure(let error):
                            print("Error fetching name for email \(email): \(error.localizedDescription)")
                        }
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
                    fetchUserName(for: email) { result in
                        switch result {
                        case .success(let name):
                            names.append(name.components(separatedBy: " ")[0])  // Add only the first name
                        case .failure(let error):
                            print("Error fetching name for email \(email): \(error.localizedDescription)")
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
    // Updates the display name of a conversation.
    func updateConversationName(conversation: Conversation, newName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("conversations").whereField("id", isEqualTo: conversation.id).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents, let document = documents.first else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No matching conversation found"])))
                return
            }
            document.reference.updateData([
                "displayName": newName
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    // Converts a single conversation into a group.
    func convertToGroup(conversation: Conversation, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("conversations").document(conversation.id).updateData([
            "isGroup": true
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    
}

