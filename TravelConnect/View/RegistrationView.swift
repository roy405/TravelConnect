//
//  RegistrationView.swift
//  TravelConnect
//
//  Created by Cube on 10/22/23.
//

import SwiftUI

struct RegistrationView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8.0)

            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8.0)

            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8.0)

            Button(action: {
                if password == confirmPassword {
                    viewModel.register(email: email, password: password)
                } else {
                    print("Passwords do not match!")
                    // Optionally, you can display a user-friendly alert to notify about the mismatch.
                }
            }) {
                Text("Register")
            }

            Spacer()
        }
        .padding()
    }
}


