//
//  UserProfileViewModel.swift
//  TravelConnect
//
//  Created by Cube on 10/28/23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

// `UserProfileViewModel` is responsible for fetching, updating, and deleting user profile and interests from Firestore.
class UserProfileViewModel: ObservableObject {
    // Observable variables for user and interests
    @Published var user: User? = nil
    @Published var interestsData: Interests?
    @Published var fetchError: Error?
    
    // Variables for db and auth view model
    private var db = Firestore.firestore()
    private var authVM: AuthViewModel
    
    // Initializer
    init(authViewModel: AuthViewModel) {
        self.authVM = authViewModel
    }
    
    // Fetches the user's profile based on their email
    func fetchUserProfile(email: String) {
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if let error = error {
                // Update the error publisher
                self.fetchError = error
                return
            }
            
            guard let userDocument = querySnapshot?.documents.first else {
                self.fetchError = NSError(domain: "UserProfileViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "User profile not found."])
                return
            }
            
            if var user = User(documentData: userDocument.data()) {
                // Fetch the interests and aboutMe for the user
                self.fetchUserInterests(email: email, completion: { interests, aboutMe in
                    user.interests = interests
                    user.aboutMe = aboutMe
                    self.user = user
                })
            }
        }
    }
    
    // Fetches the user's interests and 'about me' information
    func fetchUserInterests(email: String, completion: @escaping ([String], String) -> Void) {
        db.collection("userInterests").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if let error = error {
                // Update the error publisher
                self.fetchError = error
                completion([], "")
                return
            }
            
            guard let interestsDocument = querySnapshot?.documents.first else {
                self.fetchError = NSError(domain: "UserProfileViewModel", code: -2, userInfo: [NSLocalizedDescriptionKey: "User interests not found."])
                completion([], "")
                return
            }
            
            let interests = interestsDocument.data()["interests"] as? [String] ?? []
            let aboutMe = interestsDocument.data()["aboutMe"] as? String ?? ""
            completion(interests, aboutMe)
        }
    }
    
    // Function that handles updating the user's profile
    func updateProfile(firstName: String, lastName: String, email: String, city: String, country: String, street: String, postcode: String, age: Int, aboutMe: String, interests: [String]) {
        
        // Getting both userscollcetiona nd interestscollections
        let usersCollection = db.collection("users")
        let userInterestsCollection = db.collection("userInterests")
        let query = usersCollection.whereField("email", isEqualTo: email)
        
        //getting all for the current user using email
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                self.fetchError = error
                return
            }
            
            if let document = querySnapshot?.documents.first {
                let documentID = document.documentID
                // Update general user data
                usersCollection.document(documentID).updateData([
                    "firstName": firstName,
                    "lastName": lastName,
                    "city": city,
                    "country": country,
                    "street": street,
                    "postcode": postcode,
                    "age": age
                ]) { error in
                    if let error = error {
                        print("Error updating user: \(error.localizedDescription)")
                        return
                    }
                    
                    // Update interests and aboutMe in userInterests collection
                    userInterestsCollection.document(email).setData([
                        "aboutMe": aboutMe,
                        "interests": interests
                    ], merge: true) { error in
                        if let error = error {
                            self.fetchError = error
                            return
                        }
                        
                        self.fetchUserProfile(email: email)
                    }
                }
            } else {
                self.fetchError = NSError(domain: "UserProfileViewModel", code: -3, userInfo: [NSLocalizedDescriptionKey: "User not found."])
            }
        }
    }
    
    // Function that handle Deletion of a user's Profile
    func deleteProfile(completion: @escaping (Error?) -> Void) {
        guard let email = Auth.auth().currentUser?.email else {
            completion(NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Current user email not found."]))
            return
        }
        
        // Delete user from FirebaseAuth
        Auth.auth().currentUser?.delete { authError in
            if let authError = authError {
                completion(authError)
                return
            }
            
            let db = Firestore.firestore()
            
            // Delete user from Firestore 'users' collection
            db.collection("users").whereField("email", isEqualTo: email).getDocuments { (snapshot, error) in
                if let error = error {
                    completion(error)
                    return
                }
                
                guard let doc = snapshot?.documents.first else {
                    completion(nil)
                    return
                }
                
                db.collection("users").document(doc.documentID).delete { error in
                    if let error = error {
                        completion(error)
                        return
                    }
                    
                    // Delete user from Firestore 'userInterests' collection
                    db.collection("userInterests").whereField("email", isEqualTo: email).getDocuments { (snapshot, error) in
                        if let error = error {
                            completion(error)
                            return
                        }
                        
                        guard let doc = snapshot?.documents.first else {
                            completion(nil)
                            return
                        }
                        
                        db.collection("userInterests").document(doc.documentID).delete { error in
                            if let error = error {
                                completion(error)
                                return
                            }
                            
                            self.authVM.logout()
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
    
    // Loads interests from a bundled JSON file
    func loadInterestsFromJSON() throws {
        guard let url = Bundle.main.url(forResource: "interestsJSON", withExtension: "json") else {
            throw AppError.missingResource
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            self.interestsData = try decoder.decode(Interests.self, from: data)
        } catch let decodingError {
            throw AppError.decodingError(decodingError)
        }
    }
    
    // Fetches the interests of the currently logged in user
    func fetchCurrentUserInterests(completion: @escaping (Result<[String], AppError>) -> Void) {
        guard let email = authVM.currentUserEmail, !email.isEmpty else {
            completion(.failure(.invalidCurrentUserEmail))
            return
        }
        let docRef = Firestore.firestore().collection("userInterests").document(email)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let interests = document.data()?["interests"] as? [String] ?? []
                completion(.success(interests))
            } else if let error = error {
                completion(.failure(.firestoreError(error)))
            } else {
                completion(.failure(.documentDoesNotExist))
            }
        }
    }
    
    // Fetches the interests of all users except the currently logged in user
    func fetchOtherUsersInterests(completion: @escaping (Result<[String: [String]], AppError>) -> Void) {
        var allInterests: [String: [String]] = [:]
        Firestore.firestore().collection("userInterests").getDocuments() { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                if let error = error {
                    completion(.failure(.firestoreError(error)))
                } else {
                    completion(.failure(.documentDoesNotExist))
                }
                return
            }
            for document in documents {
                let userEmail = document.documentID
                if userEmail != self.authVM.currentUserEmail {
                    allInterests[userEmail] = document.data()["interests"] as? [String] ?? []
                }
            }
            completion(.success(allInterests))
        }
    }
}
