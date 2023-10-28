//
//  AuthViewModel.swift
//  TravelConnect
//
//  Created by Cube on 10/22/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    
    @Published var alertItem: AuthAlert?
    @Published var isSignedIn: Bool = false
    
    var currentUserEmail: String? {
        return Auth.auth().currentUser?.email
    }

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
    
    func register(email: String, password: String, firstName: String, lastName: String, city: String, country: String, street: String, postcode: String, age: Int) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error registering: \(error.localizedDescription)")
                self.alertItem = .registrationError
            } else {
                guard let uid = result?.user.uid else { return }
                
                let user = User(id: uid, firstName: firstName, lastName: lastName, email: email, city: city, country: country, street: street, postcode: postcode, age: age)
                
                self.saveProfileData(user: user) { error in
                    if let error = error {
                        print("Error saving user data: \(error.localizedDescription)")
                        self.alertItem = .registrationError
                    } else {
                        // Create an entry in the userInterests collection after the profile data has been saved
                        self.saveUserInterestsData(email: email) { error in
                            if let error = error {
                                print("Error saving user interests data: \(error.localizedDescription)")
                                self.alertItem = .registrationError
                            } else {
                                self.alertItem = .registrationSuccess
                            }
                        }
                    }
                }
            }
        }
    }

    private func saveProfileData(user: User, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        let userData: [String: Any] = [
            "id": user.id,
            "firstName": user.firstName,
            "lastName": user.lastName,
            "email": user.email,
            "city": user.city,
            "country": user.country,
            "street": user.street,
            "postcode": user.postcode,
            "age": user.age
        ]
        
        db.collection("users").document(user.id).setData(userData) { error in
            completion(error)
        }
    }
    
    private func saveUserInterestsData(email: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        // Create the initial data for the userInterests collection
        let userInterestsData: [String: Any] = [
            "email": email,
            "interests": [String](),
            "aboutMe": ""
        ]
        
        db.collection("userInterests").document(email).setData(userInterestsData) { error in
            completion(error)
        }
    }
}
