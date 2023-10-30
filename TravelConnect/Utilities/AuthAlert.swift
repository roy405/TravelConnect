//
//  AuthAlert.swift
//  TravelConnect
//
//  Created by Cube on 10/22/23.
//

import Foundation

// Enum representing various authentication related alerts.
enum AuthAlert: Identifiable {
    
    // Alert cases
    case loginSuccess                // Login was successful
    case registrationSuccess         // Registration was successful
    case emailOrPasswordError        // There was an issue with either email or password
    case passwordMismatch            // The passwords provided don't match
    case emailFieldIssue             // There is an issue with the email field input
    case emailAlreadyExists          // The email provided already exists
    case registrationError           // General error during registration
    case signoutError                //

    // Property to identify each alert uniquely.
    var message: String {
        switch self {
        case .loginSuccess:
            return "Login was successful!"
        case .registrationSuccess:
            return "Registration was successful!"
        case .emailOrPasswordError:
            return "There was an issue with either email or password."
        case .passwordMismatch:
            return "The passwords provided don't match."
        case .emailFieldIssue:
            return "There is an issue with the email field input."
        case .emailAlreadyExists:
            return "The email provided already exists."
        case .registrationError:
            return "There was a general error during registration."
        case .signoutError:
            return "An error occurred while signing out."
        }
    }
    
    // Using the message as the unique identifier
    var id: String {
        return message
    }
}

