//
//  UserProfileView.swift
//  TravelConnect
//
//  Created by Cube on 10/28/23.
//

import SwiftUI

// This is the view responsible for displaying and editing the user's profile.
struct UserProfileView: View {
    // Environment property to dismiss the view
    @Environment(\.presentationMode) var presentationMode
    // ViewModel that provides the data and operations related to the user profile.
    @ObservedObject var viewModel: UserProfileViewModel
    
    // State properties that track changes in the UI.
    // These properties store temporary changes before being saved
    @State private var isEditing = false
    @State private var tempFirstName = ""
    @State private var tempLastName = ""
    @State private var tempEmail = ""
    @State private var tempCity = ""
    @State private var tempCountry = ""
    @State private var tempStreet = ""
    @State private var tempPostcode = ""
    @State private var tempAge = 0
    @State private var tempAboutMe = ""
    @State private var originalInterests: [String] = [] // Data from ViewModel
    @State private var tempInterests: [String] = []     // Temporary changes made by user
    @State private var currentInterest = ""
    
    // State properties for managing alerts, interest selections and modals.
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedInterests: [String] = []
    @State private var showingInterestsSheet = false
    @State private var selectedInterest: String? = nil
    
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerView
                profileImageView
                if isEditing {
                    editingFields
                } else {
                    displayFields
                }
                editSaveButton
                resetPasswordButton
                deleteButton
            }
            .padding([.top, .horizontal], 20)
        }
        .onAppear {
            // Load the user details and interests when the view appears.
            do {
                loadUserDetails()
                try viewModel.loadInterestsFromJSON()
            } catch {
                // Handle the error, for instance, print the error or show a user alert.
                print("Error: \(error.localizedDescription)")
            }
        }

    }
    
    // These computed properties break down the different
    // sections of the UI for readability and modularity.
    var headerView: some View {
        Text("User Profile")
            .font(.largeTitle)
            .fontWeight(.semibold)
    }
    
    var profileImageView: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color(red: 0.0196, green: 0.2941, blue: 0.2863), lineWidth: 3))
            .shadow(radius: 5)
            .padding(.bottom, 20)
    }
    
    var editingFields: some View {
        VStack(alignment: .leading, spacing: 15) {
            TextField("First Name", text: $tempFirstName)
            TextField("Last Name", text: $tempLastName)
            TextField("Email", text: $tempEmail)
            TextField("City", text: $tempCity)
            TextField("Country", text: $tempCountry)
            TextField("Street", text: $tempStreet)
            TextField("Postcode", text: $tempPostcode)
            Stepper("Age: \(tempAge)", value: $tempAge, in: 0...100)
            TextField("About Me", text: $tempAboutMe)
            
            Button(action: {
                self.showingInterestsSheet.toggle()
            }) {
                HStack {
                    Text("Add Interest")
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(red: 0.0196, green: 0.2941, blue: 0.2863))
                }
            }
            .sheet(isPresented: $showingInterestsSheet) {
                interestSelectionView
            }
            
            .padding(.vertical, 10)
            
            if !tempInterests.isEmpty {
                Text("Selected Interests:")
                    .font(.headline)
                    .padding(.top, 10)
                ForEach(tempInterests, id: \.self) { interest in
                    Text(interest)
                        .font(.subheadline)
                }
            }
        }
        .padding(15)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    var interestSelectionView: some View {
        VStack {
            HStack {
                Spacer()
                Button("Done") {
                    self.showingInterestsSheet.toggle()
                }
                .padding()
            }
            List(viewModel.interestsData?.allCategories() ?? [], id: \.key) { category in
                Section(header: Text(category.key.replacingOccurrences(of: "_", with: " "))) {
                    ForEach(category.value, id: \.self) { interest in
                        Button(action: {
                            toggleInterest(interest: interest)
                            print("Temp int \(tempInterests)")
                        }) {
                            HStack {
                                Text(interest)
                                Spacer()
                                if tempInterests.contains(interest) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }.foregroundColor(Color(red: 0.0196, green: 0.2941, blue: 0.2863))
        }
    }
    
    
    func toggleInterest(interest: String) {
        if let index = tempInterests.firstIndex(of: interest) {
            tempInterests.remove(at: index)
        } else {
            tempInterests.append(interest)
        }
    }
    
    
    var displayFields: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("\(viewModel.user?.firstName ?? "John") \(viewModel.user?.lastName ?? "Doe")")
                .font(.headline)
                .fontWeight(.bold)
            
            // Added this section for the "About Me" text box
            if let aboutMe = viewModel.user?.aboutMe, !aboutMe.isEmpty {
                Text("About Me:")
                    .font(.headline)
                Text(aboutMe)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10) // Padding for spacing
            }
            
            Text(viewModel.user?.email ?? "example@email.com")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(viewModel.user?.street ?? "123 Example St.")
            Text(viewModel.user?.city ?? "City")
            Text(viewModel.user?.country ?? "Country")
            Text(viewModel.user?.postcode ?? "12345")
            Text("Age: \(viewModel.user?.age ?? 0)")
            
            // Display Interests
            if let interests = viewModel.user?.interests, !interests.isEmpty {
                Text("Interests:")
                    .font(.headline)
                    .padding(.top, 10) // Padding for spacing
                ForEach(interests, id: \.self) { interest in
                    Text(interest)
                        .font(.subheadline)
                }
            }
        }
    }
    
    var editSaveButton: some View {
        Button(action: {
            if isEditing {
                viewModel.updateProfile(
                    firstName: tempFirstName,
                    lastName: tempLastName,
                    email: tempEmail,
                    city: tempCity,
                    country: tempCountry,
                    street: tempStreet,
                    postcode: tempPostcode,
                    age: tempAge,
                    aboutMe: tempAboutMe,
                    interests: tempInterests
                )
            }
            isEditing.toggle()
        }) {
            Text(isEditing ? "Save Changes" : "Edit Profile")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.0196, green: 0.2941, blue: 0.2863))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.top, 15)
    }
    
    var deleteButton: some View {
        Button(action: {
            viewModel.deleteProfile { error in
                if let error = error {
                    alertMessage = error.localizedDescription
                    showAlert = true
                } else {
                    // handle successful deletion if needed
                }
            }
        }) {
            Text("Delete Profile")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.top, 15)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    var resetPasswordButton: some View {
        Button(action: {
            if let email = viewModel.user?.email {
                AuthViewModel().resetPassword(email: email) { success, message in
                    alertMessage = message
                    showAlert = true
                }
            } else {
                alertMessage = "Failed to get user email."
                showAlert = true
            }
        }) {
            Text("Reset Password")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.top, 15)
    }
    
    // This function loads user details from the ViewModel and populates the temporary state properties.
    func loadUserDetails() {
        tempFirstName = viewModel.user?.firstName ?? ""
        tempLastName = viewModel.user?.lastName ?? ""
        tempEmail = viewModel.user?.email ?? ""
        tempCity = viewModel.user?.city ?? ""
        tempCountry = viewModel.user?.country ?? ""
        tempStreet = viewModel.user?.street ?? ""
        tempPostcode = viewModel.user?.postcode ?? ""
        tempAge = viewModel.user?.age ?? 0
        tempAboutMe = viewModel.user?.aboutMe ?? ""
        originalInterests = viewModel.user?.interests ?? []
        tempInterests = originalInterests
        
        tempInterests = viewModel.user?.interests ?? []
        for category in viewModel.interestsData?.allCategories() ?? [] {
            for interest in category.value {
                if tempInterests.contains(interest) {
                    selectedInterests.append(interest)
                }
            }
        }
    }
}

// This extension is for organizing and accessing interests categories.
extension Interests {
    func allCategories() -> [Dictionary<String, [String]>.Element] {
        return [
            ("Nature & Outdoors", natureAndOutdoors),
            ("Cultural & Historical", culturalAndHistorical),
            ("Relaxation", relaxation),
            ("Urban & Modern", urbanAndModern),
            ("Adventurous & Extreme", adventurousAndExtreme),
            ("Recreational & Sports", recreationalAndSports),
            ("Educational", educational),
            ("Eco & Responsible", ecoAndResponsible),
            ("Luxury & Exclusive", luxuryAndExclusive),
            ("Niche & Specific", nicheAndSpecific),
            ("Family & Group", familyAndGroup)
        ]
    }
}

