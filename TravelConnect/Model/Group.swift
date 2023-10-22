//
//  Group.swift
//  TravelConnect
//
//  Created by Cube on 10/18/23.
//

import Foundation

struct Group: Codable, Identifiable {
    let id: UUID
    var name: String
    var members: [People] // List of people in the group
}

