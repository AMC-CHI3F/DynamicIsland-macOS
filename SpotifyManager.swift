import Foundation
import AppKit
import Combine

class SpotifyManager: ObservableObject {
    @Published var currentTrack: String = "Not Playing"
    @Published var currentArtist: String = ""
    @Published var albumArtURL: String = ""
    @Published var isPlaying: Bool = false
    
    private var timer: Timer?

    init() {
        startMonitoring()
    }

    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.fetchSpotifyState()
        }
    }

    func fetchSpotifyState() {
        let script = """
        tell application "System Events"
            if exists (process "Spotify") then
                tell application "Spotify"
                    if player state is playing or player state is paused then
                        set trackName to name of current track
                        set artistName to artist of current track
                        set artURL to artwork url of current track
                        set playerState to player state as string
                        return trackName & "|||" & artistName & "|||" & artURL & "|||" & playerState
                    end if
                end tell
            end if
        end tell
        return "IDLE"
        """

        DispatchQueue.global(qos: .userInitiated).async {
            var error: NSDictionary?
            if let scriptObject = NSAppleScript(source: script) {
                let output = scriptObject.executeAndReturnError(&error)
                if let resultString = output.stringValue, resultString != "IDLE" {
                    let parts = resultString.components(separatedBy: "|||")
                    if parts.count >= 4 {
                        let track = parts[0]
                        let artist = parts[1]
                        let artURL = parts[2]
                        let playing = (parts[3] == "playing")

                        DispatchQueue.main.async {
                            self.currentTrack = track
                            self.currentArtist = artist
                            self.albumArtURL = artURL
                            self.isPlaying = playing
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.currentTrack = "Spotify Closed"
                        self.currentArtist = ""
                        self.albumArtURL = ""
                        self.isPlaying = false
                    }
                }
            }
        }
    }

    // MARK: - Playback Controls
    
    func playPause() {
        runAppleScript("tell application \"Spotify\" to playpause")
    }

    func nextTrack() {
        runAppleScript("tell application \"Spotify\" to next track")
    }

    func previousTrack() {
        runAppleScript("tell application \"Spotify\" to previous track")
    }

    private func runAppleScript(_ command: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            var error: NSDictionary?
            if let scriptObject = NSAppleScript(source: command) {
                scriptObject.executeAndReturnError(&error)
            }
        }
    }
}
