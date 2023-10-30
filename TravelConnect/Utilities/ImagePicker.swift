//
//  File.swift
//  TravelConnect
//
//  Created by Cube on 10/29/23.
//

import SwiftUI
import Foundation

// A view controller representable for SwiftUI to pick images.
struct ImagePicker: UIViewControllerRepresentable {

    // Bindings related to the selected image and image picker visibility.
    @Binding var image: UIImage?
    @Binding var isShown: Bool
    @Binding var error: ImagePickerError? 
    
    // Function to create a `UIImagePickerController`.
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    // Function to update the  `UIImagePickerController`.
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
    
    // Function to create a coordinator for the image picker.
    func makeCoordinator() -> Coordinator {
        return Coordinator(image: $image, isShown: $isShown, error: $error)
    }
    
    // Coordinator for the `ImagePicker` to manage its delegate methods.
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var image: UIImage?
        @Binding var isShown: Bool
        @Binding var error: ImagePickerError?
        
        // Initializer
        init(image: Binding<UIImage?>, isShown: Binding<Bool>, error: Binding<ImagePickerError?>) {
            _image = image
            _isShown = isShown
            _error = error
        }
        
        // Function to handle the image picker's selection.
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                image = uiImage
            } else {
                error = .invalidImage  // Set the error state to represent an invalid image
            }
            isShown = false
        }
        
        // Handle the image picker's cancellation.
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isShown = false
        }
    }
}

// Enum definition for Errors from Image Picker
enum ImagePickerError: Identifiable, Error {
    case invalidImage

    var id: Int {
        switch self {
        case .invalidImage:
            return 1
        }
    }
}
