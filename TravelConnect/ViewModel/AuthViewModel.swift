//
//  AuthViewModel.swift
//  TravelConnect
//
//  Created by Cube on 10/22/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

// ViewModel responsible for handling user authentication tasks.
class AuthViewModel: ObservableObject {
    // Handler to manage the authentication state change listener.
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    
    // Published properties to trigger appropriate alerts and representing the current user's sign-in status.
    @Published var alertItem: AuthAlert?
    @Published var isSignedIn: Bool = false
    
    // Property to get the current user's email.
    var currentUserEmail: String? {
        return Auth.auth().currentUser?.email
    }
    
    // Viewmodel initializer with addAuthListener at creation
    init() {
        addAuthListener()
    }
    
    // deinitialier with the removeAuthListner at destruction
    deinit {
        removeAuthListener()
    }
    
    // Function to add an authentication listener to monitor changes in user sign-in status.
    func addAuthListener() {
        if authStateDidChangeListenerHandle == nil {
            authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { (_, user) in
                self.isSignedIn = user != nil
            }
        }
    }
    
    // Function to remove  the currently active authentication listener.
    func removeAuthListener() {
        if let handle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
            authStateDidChangeListenerHandle = nil
        }
    }
    
    // Function that attempts to login a user with the given credentials.
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            self.alertItem = error == nil ? .loginSuccess : .emailOrPasswordError
        }
    }
    
    // Function that attempt to log out the current user.
    func logout() {
        do {
            try Auth.auth().signOut()
            self.isSignedIn = false
        } catch {
            self.alertItem = .signoutError
        }
    }
    
    // Function that attempts to register a new user with detailed information.
    func register(email: String, password: String, firstName: String, lastName: String, city: String, country: String, street: String, postcode: String, age: Int) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.alertItem = .registrationError
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            let user = User(id: uid, firstName: firstName, lastName: lastName, email: email, city: city, country: country, street: street, postcode: postcode, age: age)
            // Save the user's profile data.
            self.saveProfileData(user: user) { error in
                if let error = error {
                    self.alertItem = .registrationError
                    return
                }
                // Save the user's interests data.
                self.saveUserInterestsData(email: email) { error in
                    if let error = error {
                        self.alertItem = .registrationError
                    } else {
                        self.alertItem = .registrationSuccess
                    }
                }
            }
        }
    }
    
    // Function handle saving user profile data to firestore
    private func saveProfileData(user: User, completion: @escaping (Error?) -> Void) {
        // Firestore variable
        let db = Firestore.firestore()
        // User data dictionary for firestore
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
        // Call to firestore to save the profile data
        db.collection("users").document(user.id).setData(userData, completion: completion)
    }
    
    // Private helper function to save a user's interests data to Firestore.
    private func saveUserInterestsData(email: String, completion: @escaping (Error?) -> Void) {
        // Firestore variable
        let db = Firestore.firestore()
        
        // user Interests dictionary for firestore
        let userInterestsData: [String: Any] = [
            "email": email,
            "interests": [String](),
            "aboutMe": ""
        ]
        // Firestore call to save interests data
        db.collection("userInterests").document(email).setData(userInterestsData, completion: completion)
    }
    
    // Function that handle resetting of user password by invoking fire store to send an email
    // with password changing instructions to the currently logged in user
    func resetPassword(email: String, completion: @escaping (Bool, String) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true, "A password reset email has been sent to \(email).")
            }
        }
    }
}
