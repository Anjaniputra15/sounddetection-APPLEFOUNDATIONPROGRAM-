//
//  PredicitonDealing.swift
//  PredicitonDealing
//
//  Created by Dmitrii on 08.08.2021.
//

import AVKit
import SoundAnalysis
import SwiftUI

class PredictionDealing: ObservableObject, MyBirdsClassifier3Delegate {

    @Published var pubResult:Birds
    private let audioEngine = AVAudioEngine()
    private var soundClassifier = try! MyBirdsClassifier4()

    func displayPredictionResult(identifier: String, confidence: Double) {
        DispatchQueue.main.async {
            self.pubResult.confidence = confidence / 100
            self.pubResult.name = identifier

        }

    }

    var inputFormat: AVAudioFormat!
    var analyzer: SNAudioStreamAnalyzer!
    var resultsObserver = ResultsObserver()
    let analysisQueue = DispatchQueue(label: "com.custom.AnalyseQueue")

    init() {

        pubResult = Birds(name: "", confidence: 0.0)
        resultsObserver.delegate = self
        inputFormat = audioEngine.inputNode.inputFormat(forBus: 0)
        analyzer = SNAudioStreamAnalyzer(format: inputFormat)

    }

    public  func startAudioEngine() {
        do {
            let request = try SNClassifySoundRequest(mlModel: soundClassifier.model)
            try analyzer.add(request, withObserver: resultsObserver)
        } catch {
            print("Unable to prepare request: \(error.localizedDescription)")
            return
        }

        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 8000, format: inputFormat) { buffer, time in
            self.analysisQueue.async {
                self.analyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
            }
        }

        do {
            try audioEngine.start()
        } catch( _) {
            print("error in starting Audio Engine")
        }
    }

}

protocol MyBirdsClassifier3Delegate {
    func displayPredictionResult(identifier: String, confidence: Double)
}

class ResultsObserver: NSObject, SNResultsObserving {
     var delegate: MyBirdsClassifier3Delegate?
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult,
              let classification = result.classifications.first else { return }

        let confidence = classification.confidence * 100.0

        if confidence > 80 {
            delegate?.displayPredictionResult(identifier: classification.identifier, confidence: confidence)
        }
    }
}
