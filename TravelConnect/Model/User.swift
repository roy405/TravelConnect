//
//  File.swift
//  TravelConnect
//
//  Created by Cube on 10/18/23.
//

import Foundation

struct User {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let city: String
    let country: String
    let street: String
    let postcode: String
    let age: Int

    // Direct initializer
    init(id: String, firstName: String, lastName: String, email: String, city: String, country: String, street: String, postcode: String, age: Int) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.city = city
        self.country = country
        self.street = street
        self.postcode = postcode
        self.age = age
    }

    // Convert Firestore Document to User
    init?(documentData: [String: Any]) {
        guard let id = documentData["id"] as? String,
              let firstName = documentData["firstName"] as? String,
              let lastName = documentData["lastName"] as? String,
              let email = documentData["email"] as? String,
              let city = documentData["city"] as? String,
              let country = documentData["country"] as? String,
              let street = documentData["street"] as? String,
              let postcode = documentData["postcode"] as? String,
              let age = documentData["age"] as? Int else {
            return nil
        }

        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.city = city
        self.country = country
        self.street = street
        self.postcode = postcode
        self.age = age
    }
}


