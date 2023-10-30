//
//  AnimationPlayerView.swift
//  TravelConnect
//
//  Created by Cube on 10/30/23.
//

import SwiftUI
import AVKit

import AVKit

struct AnimationPlayerView: UIViewControllerRepresentable {
    var url: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = AVPlayer(url: url)
        controller.showsPlaybackControls = false // hide playback controls
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player?.play()
    }
}
