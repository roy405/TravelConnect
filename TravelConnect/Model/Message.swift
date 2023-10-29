//
//  Message.swift
//  TravelConnect
//
//  Created by Cube on 10/26/23.
//

import Foundation
import FirebaseFirestore


struct Message: Identifiable {
    var id: String
    var conversationID: String
    var senderID: String
    var text: String?
    var timestamp: Date
    var mediaURL: String?  // New field to support media URLs

    init(id: String, conversationID: String, senderID: String, text: String?, timestamp: Date, mediaURL: String? = nil) {
        self.id = id
        self.conversationID = conversationID
        self.senderID = senderID
        self.text = text
        self.timestamp = timestamp
        self.mediaURL = mediaURL
    }
    
    init?(documentData: [String: Any]) {
        guard let conversationID = documentData["conversationID"] as? String,
              let senderID = documentData["senderID"] as? String,
              let timestamp = (documentData["timestamp"] as? Timestamp)?.dateValue() else {
            return nil
        }

        self.id = documentData["id"] as? String ?? ""  // Default to an empty string if the ID isn't present
        self.conversationID = conversationID
        self.senderID = senderID
        self.text = documentData["text"] as? String  // It can be nil now, as we may have media messages without text
        self.timestamp = timestamp
        self.mediaURL = documentData["mediaURL"] as? String  // New field
    }

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

