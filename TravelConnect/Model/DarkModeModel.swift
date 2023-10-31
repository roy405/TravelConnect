//
//  DarkModeModel.swift
//  TravelConnect
//
//  Created by Yangru guo on 1/11/2023.
//

import Foundation
import UIKit

struct DarkModeModel{
    
    static func toggleDarkMode(newVal:Bool){
        
        guard let firstUIScen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        
        guard let firstWindow = firstUIScen.windows.first else {
            return
        }
        
        if newVal {
            // Change to Dark Mode
            firstWindow.overrideUserInterfaceStyle = .dark
        } else {
            // Change to Light Mode
            firstWindow.overrideUserInterfaceStyle = .light
        }
    }
}
