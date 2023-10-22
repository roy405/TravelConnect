//
//  AuthViewModel.swift
//  TravelConnect
//
//  Created by Cube on 10/22/23.
//

import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    
    @Published var alertItem: AuthAlert?
    @Published var isSignedIn: Bool = false

    init() {
        addAuthListener()
    }

    deinit {
        removeAuthListener()
    }

    func addAuthListener() {
        if authStateDidChangeListenerHandle == nil {
            authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
                self.isSignedIn = user != nil
            }
        }
    }

    func removeAuthListener() {
        if let handle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
            authStateDidChangeListenerHandle = nil
        }
    }

    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let _ = error {
                self.alertItem = .emailOrPasswordError
            } else {
                self.alertItem = .loginSuccess
            }
        }
    }

    func register(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let _ = error {
                self.alertItem = .registrationError
            } else {
                self.alertItem = .registrationSuccess
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            self.isSignedIn = false
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
