//
//  UserProfileViewModel.swift
//  TravelConnect
//
//  Created by Cube on 10/28/23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserProfileViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var interestsData: Interests?
    
    private var db = Firestore.firestore()
    private var authVM: AuthViewModel
    
    
    init(authViewModel: AuthViewModel) { 
        self.authVM = authViewModel
    }
    
    func fetchUserProfile(email: String) {
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error finding user profile: \(error.localizedDescription)")
                return
            }
            
            guard let userDocument = querySnapshot?.documents.first else {
                print("User profile not found.")
                return
            }
            
            if var user = User(documentData: userDocument.data()) {
                // Now, fetch the interests and aboutMe
                self.fetchUserInterests(email: email, completion: { interests, aboutMe in
                    user.interests = interests
                    user.aboutMe = aboutMe
                    self.user = user
                })
            }
        }
    }

    func fetchUserInterests(email: String, completion: @escaping ([String], String) -> Void) {
        db.collection("userInterests").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error finding user interests: \(error.localizedDescription)")
                completion([], "")
                return
            }
            
            guard let interestsDocument = querySnapshot?.documents.first else {
                print("User interests not found.")
                completion([], "")
                return
            }
            
            let interests = interestsDocument.data()["interests"] as? [String] ?? []
            let aboutMe = interestsDocument.data()["aboutMe"] as? String ?? ""
            completion(interests, aboutMe)
        }
    }

    
    func updateProfile(firstName: String, lastName: String, email: String, city: String, country: String, street: String, postcode: String, age: Int, aboutMe: String, interests: [String]) {
        
        let usersCollection = db.collection("users")
        let userInterestsCollection = db.collection("userInterests")
        let query = usersCollection.whereField("email", isEqualTo: email)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error finding user: \(error.localizedDescription)")
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
                            print("Error updating user interests and about me: \(error.localizedDescription)")
                            return
                        }
                        
                        self.fetchUserProfile(email: email)
                    }
                }
            } else {
                print("User not found")
            }
        }
    }


    func deleteProfile(completion: @escaping (Error?) -> Void) {
            guard let email = Auth.auth().currentUser?.email else {
                completion(NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Current user email not found."]))
                return
            }
            
            // 1. Delete user from FirebaseAuth
            Auth.auth().currentUser?.delete { authError in
                if let authError = authError {
                    completion(authError)
                    return
                }
                
                let db = Firestore.firestore()
                
                // 2. Delete user from Firestore 'users' collection
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
                        
                        // 3. Delete user from Firestore 'userInterests' collection
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
    
    func loadInterestsFromJSON() {
        guard let url = Bundle.main.url(forResource: "interestsJSON", withExtension: "json") else { return }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            self.interestsData = try decoder.decode(Interests.self, from: data)
        } catch {
            print("Error decoding interests: \(error)")
        }
    }
    
    func fetchCurrentUserInterests(completion: @escaping ([String]) -> Void) {
        guard let email = authVM.currentUserEmail, !email.isEmpty else {
            print("No valid email found for the current user.")
            completion([])
            return
        }
        let docRef = Firestore.firestore().collection("userInterests").document(email)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let interests = document.data()?["interests"] as? [String] ?? []
                completion(interests)
            } else {
                print("Document does not exist")
                completion([])
            }
        }
    }

    
    func fetchOtherUsersInterests(completion: @escaping ([String: [String]]) -> Void) {
        var allInterests: [String: [String]] = [:]
        Firestore.firestore().collection("userInterests").getDocuments() { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                completion([:])
                return
            }
            for document in documents {
                let userEmail = document.documentID
                if userEmail != self.authVM.currentUserEmail {
                    allInterests[userEmail] = document.data()["interests"] as? [String] ?? []
                }
            }
            completion(allInterests)
        }
    }


}
