//
//  ImageGalleryView.swift
//  TravelConnect
//
//  Created by Yangru Guo on 29/10/2023.
//

import SwiftUI

struct ImageGalleryView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var tripDetailViewModel:TripDetailViewModel
    let imageCards = [
        "rivertest", "walking","party","swimming","fishing","hiking","archery","biking","bird watching","camping","kayaking","outdooryoga","paddleboarding","rockclimbing","running","skateboarding","surfing"
    ]
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var backgroundImage:UIImage?
    @State private var error: ImagePickerError?
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 5), GridItem(.flexible(), spacing: 5)], spacing: 5) {
                ForEach(imageCards, id: \.self) { imageName in
                    GroupBox {
                        Button(action: {
                            tripDetailViewModel.currentViewingTrip.topImage = UIImage(named: imageName)?.pngData() ?? Data()
                            dismiss()
                        }) {
                            ZStack {
                                Image(imageName)
                                    .resizable()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .cornerRadius(10)
                            }
                        }
                        .background(Color.clear)
                    }
                    .frame(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
                    .backgroundStyle(Color.clear)
                }
                if let selectedImage{
                    GroupBox {
                        Button(action: {
                            tripDetailViewModel.currentViewingTrip.topImage = selectedImage.pngData() ?? Data()
                            dismiss()
                        }) {
                            ZStack {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .backgroundStyle(Color.clear)
                    .frame(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
                    
                }
                GroupBox {
                    Button(action: {
                        isImagePickerPresented.toggle()
                    }, label: {
                        VStack {
                            Image(systemName: "plus")
                                .padding()
                                .imageScale(.large)
                            Text("From Gallery")
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    })
                }
                .frame(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
                .backgroundStyle(Color.clear)
            }
            .padding()
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $selectedImage,isShown: $isImagePickerPresented,error:$error)
            }
        }
    }
}
