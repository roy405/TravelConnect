//
//  Conversation.swift
//  TravelConnect
//
//  Created by Cube on 10/26/23.
//

import Foundation

// Represents a conversation within the chat application.
struct Conversation: Hashable, Identifiable {
    // Varialbles related to Conversation Model
    var documentID: String = ""
    var id: String
    var memberEmails: [String]
    var displayName: String
    var isGroup: Bool
    var tripID: UUID?

    
    // Initializer for creating a conversation from given parameters.
    init(documentID: String, id: String, memberEmails: [String], displayName: String, isGroup: Bool) {
        self.documentID = documentID
        self.id = id
        self.memberEmails = memberEmails
        self.displayName = displayName
        self.isGroup = isGroup
    }
    
    // Initializer for creating a conversation based on member emails and current user's email.
    init(memberEmails: [String], currentUserEmail: String, displayName: String) {
        self.id = UUID().uuidString
        self.memberEmails = memberEmails
        self.displayName = displayName
        self.isGroup = memberEmails.count > 2 || (memberEmails.count == 2 && !memberEmails.contains(currentUserEmail))
    }
    
    // Initializer to create a conversation instance from document data.
    init?(documentID: String, documentData: [String: Any]) {
        guard let id = documentData["id"] as? String,
              let memberEmails = documentData["memberEmails"] as? [String],
              let displayName = documentData["displayName"] as? String,
              let isGroup = documentData["isGroup"] as? Bool else {
            return nil
        }
        self.documentID = documentID
        self.id = id
        self.memberEmails = memberEmails
        self.displayName = displayName
        self.isGroup = isGroup
        
        if let tripIDString = documentData["tripID"] as? String, let tripUUID = UUID(uuidString: tripIDString) {
            self.tripID = tripUUID
        }
    }
    
    // Convert the conversation object to a dictionary.
    func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [
            "id": id,
            "memberEmails": memberEmails,
            "displayName": displayName,
            "isGroup": isGroup
        ]
        if let tripID = tripID {
            dictionary["tripID"] = tripID.uuidString
        }
        return dictionary
    }
}
