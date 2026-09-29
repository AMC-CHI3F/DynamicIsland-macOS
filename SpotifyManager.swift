import Foundation
import Combine

class SpotifyManager: ObservableObject {
    @Published var currentTrack: String = ""
    @Published var currentArtist: String = ""
    @Published var albumArtURL: String = ""
    @Published var isPlaying: Bool = false
    @Published var isRunning: Bool = false

    init() {
        setupObservers()
        fetchInitialState()
    }

    private func setupObservers() {
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(spotifyStateChanged(_:)),
            name: NSNotification.Name("com.spotify.client.PlaybackStateChanged"),
            object: nil
        )
    }

    @objc private func spotifyStateChanged(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let playerState = userInfo["Player State"] as? String ?? "Stopped"
            let track = userInfo["Name"] as? String ?? ""
            let artist = userInfo["Artist"] as? String ?? ""

            DispatchQueue.main.async {
                self.isPlaying = (playerState == "Playing")
                self.currentTrack = track
                self.currentArtist = artist
                self.isRunning = true
            }
            self.fetchArtwork()
        }
    }

    func fetchInitialState() {
        let script = """
        tell application "System Events"
            set processExists to (exists process "Spotify")
        end tell
        if processExists then
            tell application "Spotify"
                if player state is playing then
                    return (name of current track) & "|||" & (artist of current track) & "|||playing|||" & (artwork url of current track)
                else if player state is paused then
                    return (name of current track) & "|||" & (artist of current track) & "|||paused|||" & (artwork url of current track)
                else
                    return "||| |||stopped|||"
                end if
            end tell
        else
            return "||| |||off|||"
        end if
        """

        DispatchQueue.global(qos: .userInitiated).async {
            var error: NSDictionary?
            if let appleScript = NSAppleScript(source: script) {
                let output = appleScript.executeAndReturnError(&error)
                if let stringValue = output.stringValue {
                    let components = stringValue.components(separatedBy: "|||")
                    DispatchQueue.main.async {
                        if components.count >= 4 {
                            self.currentTrack = components[0]
                            self.currentArtist = components[1]
                            self.isPlaying = (components[2] == "playing")
                            self.isRunning = (components[2] != "off")
                            self.updateArtworkURL(components[3])
                        }
                    }
                }
            }
        }
    }

    func fetchArtwork() {
        let script = """
        tell application "System Events"
            if (exists process "Spotify") then
                tell application "Spotify"
                    return artwork url of current track
                end tell
            end if
        end tell
        return ""
        """

        DispatchQueue.global(qos: .userInitiated).async {
            if let appleScript = NSAppleScript(source: script) {
                var error: NSDictionary?
                let output = appleScript.executeAndReturnError(&error)
                if let rawUrl = output.stringValue, !rawUrl.isEmpty {
                    DispatchQueue.main.async {
                        self.updateArtworkURL(rawUrl)
                    }
                }
            }
        }
    }

    private func updateArtworkURL(_ rawUrl: String) {
        var cleanURL = rawUrl
        // Convert Spotify URI scheme to high-res direct CDN link for fast loading
        if cleanURL.hasPrefix("spotify:image:") {
            let imageID = cleanURL.replacingOccurrences(of: "spotify:image:", with: "")
            cleanURL = "https://i.scdn.co/image/\(imageID)"
        }
        if self.albumArtURL != cleanURL {
            self.albumArtURL = cleanURL
        }
    }

    func playPause() { runScript("tell application \"Spotify\" to playpause") }
    func nextTrack() { runScript("tell application \"Spotify\" to next track") }
    func previousTrack() { runScript("tell application \"Spotify\" to previous track") }

    private func runScript(_ code: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let script = NSAppleScript(source: code) {
                var error: NSDictionary?
                script.executeAndReturnError(&error)
            }
        }
    }
}