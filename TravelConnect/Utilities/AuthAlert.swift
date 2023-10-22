//
//  AuthAlert.swift
//  TravelConnect
//
//  Created by Cube on 10/22/23.
//

import Foundation

enum AuthAlert: Identifiable {
    case loginSuccess, registrationSuccess, emailOrPasswordError, passwordMismatch, emailFieldIssue, emailAlreadyExists, registrationError

    var id: Int {
        switch self {
        case .loginSuccess:
            return 1
        case .registrationSuccess:
            return 2
        case .emailOrPasswordError:
            return 3
        case .passwordMismatch:
            return 4
        case .emailFieldIssue:
            return 5
        case .emailAlreadyExists:
            return 6
        case .registrationError:
            return 7
        }
    }
}
