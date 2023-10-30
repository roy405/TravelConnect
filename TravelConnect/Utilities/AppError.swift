//
//  AppError.swift
//  TravelConnect
//
//  Created by Cube on 10/31/23.
//

import Foundation

enum AppError: Error {
    case missingResource
    case decodingError(Error)
    case invalidCurrentUserEmail
    case documentDoesNotExist
    case firestoreError(Error)
}
