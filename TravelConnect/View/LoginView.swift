//
//  LoginView.swift
//  TravelConnect
//
//  Created by Cube on 10/22/23.
//

import SwiftUI
import Firebase

// View the displays the Login Page with with Brand Logo
struct LoginView: View {
    // The view model responsible for the authentication logic.
    @ObservedObject var viewModel: AuthViewModel
    // State variables to hold the user input for email and password.
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Logo or app icon.
                Image("tConnect")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .padding(.top, 40)
                // Text field for email input.
                TextField("Email", text: $email)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).strokeBorder(Color(.systemGray6), lineWidth: 1))
                    .padding(.horizontal, 20)
                // Secure text field for password input.
                SecureField("Password", text: $password)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).strokeBorder(Color(.systemGray6), lineWidth: 1))
                    .padding(.horizontal, 20)
                // Button to trigger the login action.
                Button(action: {
                    viewModel.login(email: email, password: password)
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0.0196, green: 0.2941, blue: 0.2863))
                        .cornerRadius(15)
                }
                .padding(.horizontal, 20)
                // Navigation link to switch to the registration view.
                NavigationLink(destination: RegistrationView(viewModel: viewModel)) {
                    Text("Register")
                        .foregroundColor(Color(red: 0.0196, green: 0.2941, blue: 0.2863))
                }
                
                Spacer()
            }
            .padding()
            // Alert to provide feedback based on the login attempt's outcome.
            .alert(item: $viewModel.alertItem) { item in
                switch item {
                case .loginSuccess:
                    return Alert(title: Text("Success"), message: Text("Welcome!"), dismissButton: .default(Text("OK")))
                case .emailOrPasswordError:
                    return Alert(title: Text("Error"), message: Text("Incorrect email or password."), dismissButton: .default(Text("Retry")))
                default:
                    return Alert(title: Text("Error"), message: Text("An unknown error occurred."), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
}





