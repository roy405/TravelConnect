//
//  RegistrationView.swift
//  TravelConnect
//
//  Created by Cube on 10/22/23.
//

import SwiftUI
// View that displays the Registration form
struct RegistrationView: View {
    // Observable object for authentication view model.
    @ObservedObject var viewModel: AuthViewModel
    // State properties for user input fields.
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var city: String = ""
    @State private var country: String = ""
    @State private var street: String = ""
    @State private var postcode: String = ""
    @State private var age: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    // Property to check if the form is valid.
    var isFormValid: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !password.isEmpty && password == confirmPassword
    }
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TextField("First Name", text: $firstName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8.0)
                TextField("Last Name", text: $lastName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8.0)
                TextField("City", text: $city)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8.0)
                TextField("Country", text: $country)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8.0)
                TextField("Street", text: $street)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8.0)
                TextField("Postcode", text: $postcode)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8.0)
                TextField("Age", text: $age)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8.0)
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8.0)
                // Password Field
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8.0)
                // Password field
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8.0)
                // Registration button.
                Button(action: {
                    if password == confirmPassword {
                        let ageAsInt = Int(age) ?? 0
                        viewModel.register(email: email.lowercased(), password: password, firstName: firstName, lastName: lastName, city: city, country: country, street: street, postcode: postcode, age: ageAsInt)
                    } else {
                        alertMessage = "Passwords do not match!"
                        showAlert.toggle()
                    }
                }) {
                    Text("Register")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(25)
                }
                .disabled(!isFormValid) // Button is disabled if form is not valid.
                .opacity(isFormValid ? 1 : 0.7) // Adjust opacity based on form validity.
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                
                Spacer()
            }
            .padding()
        }
        // Observer for alertItem changes from the viewModel.
        .onReceive(viewModel.$alertItem) { alertItem in
            switch alertItem {
            case .emailOrPasswordError:
                alertMessage = "Error with email or password."
                showAlert.toggle()
            case .registrationError:
                alertMessage = "Registration failed."
                showAlert.toggle()
            case .registrationSuccess:
                alertMessage = "Successfully registered!"
                showAlert.toggle()
                // Add other cases as needed
            default:
                break
            }
        }
    }
}


