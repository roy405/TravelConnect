//
//  UserProfileView.swift
//  TravelConnect
//
//  Created by Cube on 10/28/23.
//

import SwiftUI

struct UserProfileView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    
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
    @State private var tempInterests: [String] = []
    @State private var currentInterest = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
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
                deleteButton
            }
            .padding([.top, .horizontal], 20)
        }
        .onAppear {
            loadUserDetails()
        }
    }
    
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
            .overlay(Circle().stroke(Color.blue, lineWidth: 3))
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
            HStack {
                TextField("Add Interest", text: $currentInterest)
                Button(action: {
                    tempInterests.append(currentInterest)
                    currentInterest = ""
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            List(tempInterests, id: \.self) { interest in
                Text(interest)
            }
            .frame(height: CGFloat(tempInterests.count * 40)) // Adjust as needed
        }
        .padding(15)
        .background(Color(.systemGray6))
        .cornerRadius(10)
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
                .background(Color.blue)
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
        tempInterests = viewModel.user?.interests ?? []
    }
}










