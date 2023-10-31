//
//  ShareModelView.swift
//  TravelConnect
//
//  Created by Cube on 10/30/23.
//

import SwiftUI
import FirebaseAuth
import SDWebImageSwiftUI

struct ShareModalView: View {
    @Binding var selectedImage: UIImage?
    @Binding var showImagePicker: Bool
    @State private var error: ImagePickerError?
    var viewModel: ConversationsViewModel
    var conversation: Conversation
    
    var body: some View {
        VStack {
            Spacer() // This spacer pushes content to the bottom
            
            VStack {
                NavigationView {
                    List {
                        Button(action: {
                            showImagePicker.toggle()
                        }) {
                            HStack {
                                Image(systemName: "photo")
                                    .font(.system(size: 20))
                                Text("Add Photos")
                            }
                        }
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker(image: $selectedImage, isShown: $showImagePicker, error: $error)
                                .alert(item: $error) { error in
                                    switch error {
                                    case .invalidImage:
                                        return Alert(title: Text("Error"), message: Text("Expected a UIImage, but got something else."), dismissButton: .default(Text("OK")))
                                    }
                                }
                        }
                        
                        Button(action: {
                            // TODO: Add open camera functionality
                        }) {
                            HStack {
                                Image(systemName: "camera")
                                    .font(.system(size: 20))
                                Text("Open Camera")
                            }
                        }
                        
                        Button(action: {
                            // TODO: Add publish route functionality
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.circle")
                                    .font(.system(size: 20))
                                Text("Publish Route")
                            }
                        }
                        
                        Button(action: {
                            // TODO: Add share notes functionality
                        }) {
                            HStack {
                                Image(systemName: "note.text")
                                    .font(.system(size: 20))
                                Text("Share Notes")
                            }
                        }
                        
                        Button(action: {
                            // TODO: Add share file functionality
                        }) {
                            HStack {
                                Image(systemName: "doc")
                                    .font(.system(size: 20))
                                Text("Share File")
                            }
                        }
                        
                        Button(action: {
                            // TODO: Add schedule functionality
                        }) {
                            HStack {
                                Image(systemName: "calendar")
                                    .font(.system(size: 20))
                                Text("Add Schedule")
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .navigationTitle("Share Options")
                }
            }
            .background(Color.white) // set the background color of the modal content
            .foregroundColor(Color(red: 0.0196, green: 0.2941, blue: 0.2863))
            .cornerRadius(20) // round the corners for better appearance
        }
        .edgesIgnoringSafeArea(.all) // ignore safe areas for full-screen appearance
        
        if let image = selectedImage {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 200, height: 200)
                    .padding()
                
                Button("Send Image") {
                    viewModel.uploadMediaToFirebase(image: image) { urlString in
                        guard let urlString = urlString else {
                            print("Failed to upload media.")
                            return
                        }
                        viewModel.sendMessage(conversation: conversation, text: nil, mediaURL: urlString, senderID: Auth.auth().currentUser?.uid ?? "")
                    }
                }
            }
        }
    }
}
