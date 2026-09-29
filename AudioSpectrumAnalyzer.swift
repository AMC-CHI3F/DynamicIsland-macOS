import Foundation
import SwiftUI
import Combine

class AudioSpectrumAnalyzer: ObservableObject {
    @Published var bandAmplitudes: [CGFloat] = [0.25, 0.25, 0.25, 0.25]
    
    private var timer: AnyCancellable?
    private var phase: Double = 0.0

    init() {
        startRhythmEngine()
    }

    func startRhythmEngine() {
        // Smooth 120ms tick for a relaxed beat rhythm
        timer = Timer.publish(every: 0.12, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tickRhythm()
            }
    }

    private func tickRhythm() {
        phase += 0.18
        
        // Gentle organic waves tied to sub-bass, mid, and treble frequencies
        let bass = (sin(phase * 1.2) + 1.0) * 0.3 + 0.25
        let mid1 = (cos(phase * 1.6) + 1.0) * 0.25 + 0.2
        let mid2 = (sin(phase * 1.0) + 1.0) * 0.3 + 0.15
        let treble = (cos(phase * 2.0) + 1.0) * 0.2 + 0.2

        DispatchQueue.main.async {
            self.bandAmplitudes = [
                CGFloat(min(max(bass, 0.2), 0.9)),
                CGFloat(min(max(mid1, 0.2), 0.8)),
                CGFloat(min(max(mid2, 0.2), 0.85)),
                CGFloat(min(max(treble, 0.2), 0.75))
            ]
        }
    }
}