//
//  DetectSoundsView.swift
//  DetectSoundsView
//
//  Created by Dmitrii on 07.08.2021.
//

import Foundation
import SwiftUI
import Combine
import SoundAnalysis

struct DetectSoundsView: View {

    @State var appConfig = AppConfiguration()
    @StateObject var appState = AppState()
    @ObservedObject var predictionDealing = PredictionDealing()
    var classificationSubject = PassthroughSubject<SNClassificationResult, Error>()

    static func generateConfidenceMeterBarColors(numBars: Int) -> [Color] {
        let numGreenBars = Int(Double(numBars) / 3.0)
        let numYellowBars = Int(Double(numBars) * 2 / 3.0) - numGreenBars
        let numRedBars = Int(numBars - numYellowBars)

        return [Color](repeating: .green, count: numGreenBars) +
        [Color](repeating: .yellow, count: numYellowBars) +
        [Color](repeating: .red, count: numRedBars)
    }

    static func cardify ( confidence: Double, label:String) -> some View {
        let dimensions = (CGFloat(100.0), CGFloat(200.0))
        let cornerRadius = 20.0
        let color = Color.blue
        let opacity = 0.2

        return VStack() {
            Text(label)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .frame(height: CGFloat(60))
        }
        .frame(width: dimensions.0,
               height: dimensions.1,
               alignment: .bottom
        )
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundColor(color)
                .opacity(opacity))
        .background(
            Image(label)
                .resizable()
        ) .cornerRadius(cornerRadius)
            .saturation(confidence)

    }

    static func generateMeter(confidence: Double) -> some View {
        let numBars = 20
        let barColors = generateConfidenceMeterBarColors(numBars: numBars)
        let confidencePerBar = 1.0 / Double(numBars)
        let barSpacing = CGFloat(2.0)
        let barDimensions = (CGFloat(10.0), CGFloat(2.0))
        let numLitBars = Int(confidence / confidencePerBar)
        let litBarOpacities = [Double](repeating: 1.0, count: numLitBars)
        let unlitBarOpacities = [Double](repeating: 0.1, count: numBars - numLitBars)
        let barOpacities = litBarOpacities + unlitBarOpacities

        return VStack(spacing: barSpacing) {
            ForEach(0..<numBars) {
                Rectangle()
                    .foregroundColor(barColors[numBars - 1 - $0])
                    .opacity(barOpacities[numBars - 1 - $0])
                    .frame(width: barDimensions.0, height: barDimensions.1)
            }
        }.animation(.easeInOut, value: confidence)

    }

    static func generateHorizontalMeter(confidence: Double) -> some View {
        var innerConfidence = confidence
        if BridDetectionSUITileApp.useBirdSoundConfidence != true {
            innerConfidence = 0.0
        }
        let numBars = 20
        let barColors = generateConfidenceMeterBarColors(numBars: numBars)
        let confidencePerBar = 1.0 / Double(numBars)
        let barSpacing = CGFloat(2.0)
        let barDimensions = (CGFloat(10.0), CGFloat(20.0))
        let numLitBars = Int(innerConfidence / confidencePerBar)
        let litBarOpacities = [Double](repeating: 1.0, count: numLitBars)
        let unlitBarOpacities = [Double](repeating: 0.1, count: numBars - numLitBars)
        let barOpacities = litBarOpacities + unlitBarOpacities

        return HStack(spacing: barSpacing) {

            Text("🕊")
                .font(.largeTitle)
                .colorInvert()
                .onTapGesture {
                    if BridDetectionSUITileApp.useBirdSoundConfidence {
                        BridDetectionSUITileApp.useBirdSoundConfidence = false

                    } else {
                        BridDetectionSUITileApp.useBirdSoundConfidence = true
                    }

                }
            ForEach(0..<numBars) {
                Rectangle()
                    .foregroundColor(barColors[numBars - 1 - $0])
                    .opacity(barOpacities[numBars - 1 - $0])
                    .frame(width: barDimensions.0, height: barDimensions.1)
            }
        }.animation(.easeInOut, value: innerConfidence)

    }

    static func generateMeterCard(confidence: Double,
                                  label: String) -> some View {
        return cardify(confidence: confidence, label: label)
    }

    func fullTheBirdsClasses() -> [Birds] {
        let birdsArray = try! MyBirdsClassifier4().model.modelDescription.classLabels
        var birdsForUI = [Birds]()
        for bird in birdsArray! {
            if bird as! String == predictionDealing.pubResult.name {
                if BridDetectionSUITileApp.useBirdSoundConfidence && BridDetectionSUITileApp.currentBirdSoundConfidence > 0.10 {
                    birdsForUI.append(Birds(name: predictionDealing.pubResult.name, confidence: predictionDealing.pubResult.confidence))
                } else if BridDetectionSUITileApp.useBirdSoundConfidence == false {
                    birdsForUI.append(Birds(name: predictionDealing.pubResult.name, confidence: predictionDealing.pubResult.confidence))
                } else {
                    birdsForUI.append(Birds(name: bird as! String, confidence: 0.0))
                }

            } else {
                birdsForUI.append(Birds(name: bird as! String, confidence: 0.0))
            }
        }

        return birdsForUI
    }

    func getcurrentBirdSoundConfidence() -> Double {
        return BridDetectionSUITileApp.currentBirdSoundConfidence
    }

    static func generateDetectionsGrid(_ detections: [Birds]) -> some View {
        return ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 100))],
                      spacing: 2) {
                ForEach(detections, id: \.name) {
                    generateMeterCard(confidence: $0.isDetected ? $0.confidence: 0.0,
                                      label: $0.name)
                }
            }
        }
    }

    var body: some View {
        VStack {
            ZStack {
                VStack {
                    Text("Detecting birds").font(.title).padding()
                    DetectSoundsView.generateDetectionsGrid(fullTheBirdsClasses())
                        .onAppear {
                            self.predictionDealing.startAudioEngine()
                            DispatchQueue.main.async {
                                SystemAudioClassifier.singleton.startSoundClassification(
                                    subject: classificationSubject,
                                    inferenceWindowSize: 1.5,
                                    overlapFactor: 0.9)
                            }

                        }
                    DetectSoundsView.generateHorizontalMeter(confidence: getcurrentBirdSoundConfidence())

                }
            }
        }
    }
}
