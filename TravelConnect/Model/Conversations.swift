//
//  Conversations.swift
//  TravelConnect
//
//  Created by Cube on 10/18/23.
//

import Foundation

struct Conversation: Codable, Identifiable {
    enum ConversationType: String, Codable {
        case group
        case person
    }
    
    let id: UUID
    var type: ConversationType
    var group: Group?
    var person: People?
    
    // Ensure only one of group or person is set
    init?(id: UUID = UUID(), type: ConversationType, group: Group? = nil, person: People? = nil) {
        if (group == nil && person == nil) || (group != nil && person != nil) {
            return nil
        }
        self.id = id
        self.type = type
        self.group = group
        self.person = person
    }
}
