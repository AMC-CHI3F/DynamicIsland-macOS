# Dynamic Island for macOS 🏝️

Bring the sleek, interactive Dynamic Island experience to your Mac status bar and desktop. Built using Swift and SwiftUI, this lightweight utility integrates directly with your system audio and Spotify playback.

---

## ✨ Features

- **Spotify Integration:** Displays current track info, album artwork, and media controls seamlessly.
- **Live Audio Spectrum Analyzer:** Real-time visual representation of playing audio.
- **Floating Panel UI:** Smooth, fluid SwiftUI animations anchored at the top of your screen.
- **Lightweight & Efficient:** Minimal CPU and RAM footprint tailored for macOS performance.

---

## 💻 Compatibility

- **Operating System:** macOS 11.0 (Big Sur) or newer
- **Architecture:** Universal (Supports both **Intel** and **Apple Silicon M1/M2/M3/M4** Macs)

---

## 🚀 Installation

1. Go to the Releases section of this repository.
2. Download `DynamicIsland-Universal.dmg`.
3. Open the `.dmg` file and drag **Dynamic Island** into your **Applications** folder.
4. Launch the application from Launchpad or Finder.

---

## 🛠️ Building from Source

If you prefer to compile the app manually using Terminal:

```zsh
# Clone the repository
git clone [https://github.com/AMC-CHI3F/DynamicIsland-macOS.git](https://github.com/AMC-CHI3F/DynamicIsland-macOS.git)
cd DynamicIsland-macOS

# Build executable
swiftc MyDynamicIslandApp.swift ContentView.swift IslandPanel.swift SpotifyManager.swift AudioSpectrumAnalyzer.swift -o DynamicIsland -parse-as-library
```

---

## 📄 License

Distributed under the MIT License.
