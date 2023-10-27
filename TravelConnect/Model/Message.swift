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
    var text: String
    var timestamp: Date

    init(id: String, conversationID: String, senderID: String, text: String, timestamp: Date) {
        self.id = id
        self.conversationID = conversationID
        self.senderID = senderID
        self.text = text
        self.timestamp = timestamp
    }
    
    init?(documentData: [String: Any]) {
        guard let conversationID = documentData["conversationID"] as? String,
              let senderID = documentData["senderID"] as? String,
              let text = documentData["text"] as? String,
              let timestamp = (documentData["timestamp"] as? Timestamp)?.dateValue() else {
            return nil
        }

        self.id = documentData["id"] as? String ?? ""  // Default to an empty string if the ID isn't present
        self.conversationID = conversationID
        self.senderID = senderID
        self.text = text
        self.timestamp = timestamp
    }


    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "conversationID": conversationID,
            "senderID": senderID,
            "text": text,
            "timestamp": timestamp
        ]
    }
}

