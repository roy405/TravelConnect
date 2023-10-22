//
//  File.swift
//  TravelConnect
//
//  Created by Cube on 10/18/23.
//

import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    var username: String
    var password: String 
    var email: String
    var firstName: String
    var lastName: String
    var dateJoined: Date
}

