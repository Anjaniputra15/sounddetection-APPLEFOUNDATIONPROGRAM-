//
//  BridDetectionSUITileApp.swift
//  BridDetectionSUITile
//
//  Created by Dmitrii on 07.08.2021.
//

import SwiftUI

@main
struct BridDetectionSUITileApp: App {
    static var currentBirdSoundConfidence : Double = 0.0
    static var useBirdSoundConfidence : Bool = true
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
