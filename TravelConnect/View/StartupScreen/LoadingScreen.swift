//
//  LoadingScreen.swift
//  TravelConnect
//
//  Created by Cube on 10/30/23.
//

import SwiftUI

struct LoadingScreen: View {
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all) // Set background to white

            AnimationPlayerView(url: Bundle.main.url(forResource: "loadVid", withExtension: "mp4")!)
                .edgesIgnoringSafeArea(.all) // make the video cover the full screen

        }
    }
}

