//
//  LoginView.swift
//  TravelConnect
//
//  Created by Cube on 10/22/23.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Placeholder for the company logo
                Image("tConnect")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .padding(.top, 40)

                TextField("Email", text: $email)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).strokeBorder(Color(.systemGray6), lineWidth: 1))
                    .padding(.horizontal, 20)

                SecureField("Password", text: $password)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).strokeBorder(Color(.systemGray6), lineWidth: 1))
                    .padding(.horizontal, 20)

                Button(action: {
                    viewModel.login(email: email, password: password)
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 20)

                NavigationLink(destination: RegistrationView(viewModel: viewModel)) {
                    Text("Register")
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .padding()
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





