//
//  People.swift
//  TravelConnect
//
//  Created by Cube on 10/18/23.
//

import Foundation

struct People: Codable, Identifiable {
    let id: UUID
    var name: String
    var age: Int? // Example attribute, you can replace with other attributes
    var interests: String
    var referenceUser: User? // Optional reference to a User
    // Other attributes related to the person

    // This initializer allows for the creation of a Person without needing a User reference
    init(id: UUID = UUID(), name: String, age: Int?, interests: String, referenceUser: User? = nil) {
        self.id = id
        self.name = name
        self.age = age
        self.interests = interests
        self.referenceUser = referenceUser
    }
}
