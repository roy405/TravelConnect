//
//  Message.swift
//  TravelConnect
//
//  Created by Cube on 10/26/23.
//

import Foundation
import FirebaseFirestore

// Represents a message within a conversation.
struct Message: Identifiable {
    var id: String
    var conversationID: String
    var senderID: String
    var text: String?
    var timestamp: Date
    var mediaURL: String?  // Field to store media URLs associated with the message.

    // Initializer for creating a message from given parameters.
    init(id: String, conversationID: String, senderID: String, text: String?, timestamp: Date, mediaURL: String? = nil) {
        self.id = id
        self.conversationID = conversationID
        self.senderID = senderID
        self.text = text
        self.timestamp = timestamp
        self.mediaURL = mediaURL
    }
    
    // Initializer to create a message instance from document data.
    init?(documentData: [String: Any]) {
        guard let conversationID = documentData["conversationID"] as? String,
              let senderID = documentData["senderID"] as? String,
              let timestamp = (documentData["timestamp"] as? Timestamp)?.dateValue() else {
            return nil
        }
        self.id = documentData["id"] as? String ?? ""
        self.conversationID = conversationID
        self.senderID = senderID
        self.text = documentData["text"] as? String
        self.timestamp = timestamp
        self.mediaURL = documentData["mediaURL"] as? String
    }
    
    // Convert the message object to a dictionary.
    func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [
            "id": id,
            "conversationID": conversationID,
            "senderID": senderID,
            "timestamp": timestamp
        ]
        if let text = text {
            dictionary["text"] = text
        }
        if let mediaURL = mediaURL {
            dictionary["mediaURL"] = mediaURL
        }
        return dictionary
    }
}

