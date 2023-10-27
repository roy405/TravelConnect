//
//  Conversation.swift
//  TravelConnect
//
//  Created by Cube on 10/26/23.
//

import Foundation

struct Conversation: Identifiable {
    var documentID: String = ""
    var id: String
    var memberEmails: [String]
    var displayName: String
    var isGroup: Bool
    
    init(documentID: String, id: String, memberEmails: [String], displayName: String, isGroup: Bool) {
        self.documentID = documentID
        self.id = id
        self.memberEmails = memberEmails
        self.displayName = displayName
        self.isGroup = isGroup
    }
    
    init(memberEmails: [String], currentUserEmail: String, displayName: String) {
        self.id = UUID().uuidString
        self.memberEmails = memberEmails
        self.displayName = displayName
        self.isGroup = memberEmails.count > 2 || (memberEmails.count == 2 && !memberEmails.contains(currentUserEmail))
    }
    
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
    }


    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "memberEmails": memberEmails,
            "displayName": displayName,
            "isGroup": isGroup
        ]
    }
}

