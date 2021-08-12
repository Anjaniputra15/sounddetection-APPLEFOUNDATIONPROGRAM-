//
//  ContentView.swift
//  BridDetectionSUITile
//
//  Created by Dmitrii on 07.08.2021.
//

import SwiftUI
import AVKit
import SoundAnalysis
import Combine

struct ContentView: View {
    var body: some View {
        DetectSoundsView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
