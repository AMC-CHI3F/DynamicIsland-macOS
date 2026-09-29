import SwiftUI

struct AlbumArtView: View {
    let urlString: String
    let size: CGFloat
    @State private var loadedImage: Image?

    var body: some View {
        ZStack {
            if let loadedImage = loadedImage {
                loadedImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            } else {
                placeholderView
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
        .onChange(of: urlString) { newURL in
            loadImage(from: newURL)
        }
        .onAppear {
            loadImage(from: urlString)
        }
    }

    private func loadImage(from stringURL: String) {
        guard let url = URL(string: stringURL), !stringURL.isEmpty else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let nsImage = NSImage(data: data) {
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.loadedImage = Image(nsImage: nsImage)
                    }
                }
            }
        }.resume()
    }

    private var placeholderView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(colors: [.green.opacity(0.85), .black], startPoint: .topLeading, endPoint: .bottomTrailing))
            Image(systemName: "music.note")
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

struct WaveformView: View {
    @StateObject private var audioAnalyzer = AudioSpectrumAnalyzer()
    let isPlaying: Bool

    var body: some View {
        HStack(spacing: 2.5) {
            ForEach(0..<4) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.green)
                    .frame(
                        width: 3,
                        height: isPlaying ? max(4, audioAnalyzer.bandAmplitudes[index] * 16) : 3
                    )
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.85),
                        value: isPlaying ? audioAnalyzer.bandAmplitudes[index] : 0.1
                    )
            }
        }
        .frame(height: 16)
        .animation(.easeInOut(duration: 0.3), value: isPlaying)
    }
}

struct ContentView: View {
    @StateObject private var spotify = SpotifyManager()
    @State private var isExpanded = false
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false

    var body: some View {
        ZStack {
            VStack {
                if isExpanded {
                    // EXPANDED VIEW
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            AlbumArtView(urlString: spotify.albumArtURL, size: 44)
                                .scaleEffect(spotify.isPlaying ? 1.02 : 0.98)
                                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: spotify.isPlaying)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(spotify.isPlaying || !spotify.currentTrack.isEmpty ? spotify.currentTrack : "Idle")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .id("exp-title-" + spotify.currentTrack)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)
                                    ))

                                Text(spotify.currentArtist.isEmpty ? "Spotify" : spotify.currentArtist)
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }

                            Spacer()

                            Button(action: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                                    isExpanded = false
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray.opacity(0.7))
                            }
                            .buttonStyle(.plain)
                        }

                        // MEDIA CONTROLS
                        HStack(spacing: 32) {
                            Button(action: {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                                    spotify.previousTrack()
                                }
                            }) {
                                Image(systemName: "backward.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.9))
                            }.buttonStyle(.plain)

                            Button(action: {
                                withAnimation(.spring(response: 0.28, dampingFraction: 0.55)) {
                                    spotify.playPause()
                                }
                            }) {
                                Image(systemName: spotify.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .scaleEffect(spotify.isPlaying ? 1.0 : 0.9)
                            }.buttonStyle(.plain)

                            Button(action: {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
                                    spotify.nextTrack()
                                }
                            }) {
                                Image(systemName: "forward.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.9))
                            }.buttonStyle(.plain)
                        }
                        .padding(.top, 2)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .transition(.opacity.combined(with: .scale(scale: 0.94)))
                } else {
                    // COMPACT VIEW
                    HStack(spacing: 10) {
                        if spotify.isPlaying {
                            WaveformView(isPlaying: spotify.isPlaying)
                            
                            Text(spotify.currentTrack)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .id("comp-title-" + spotify.currentTrack)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))

                            Spacer()
                            
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                                .shadow(color: .green.opacity(0.6), radius: 4, x: 0, y: 0)
                        } else {
                            Circle()
                                .fill(Color.green.opacity(0.8))
                                .frame(width: 7, height: 7)
                            
                            Spacer()
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 10, weight: .light))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .padding(.horizontal, 12)
                    .transition(.opacity)
                }
            }
            .frame(width: isExpanded ? 320 : (spotify.isPlaying ? 220 : 120), height: isExpanded ? 96 : 34)
            .background(Color.black)
            .cornerRadius(isExpanded ? 24 : 17)
            .overlay(
                RoundedRectangle(cornerRadius: isExpanded ? 24 : 17)
                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.5), radius: isDragging ? 20 : 12, x: 0, y: isDragging ? 10 : 6)
            .scaleEffect(isDragging ? 1.04 : 1.0)
            .rotation3DEffect(
                .degrees(isDragging ? Double(dragOffset.width * 0.08) : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .rotation3DEffect(
                .degrees(isDragging ? Double(-dragOffset.height * 0.08) : 0),
                axis: (x: 1, y: 0, z: 0)
            )
            .offset(x: dragOffset.width, y: dragOffset.height)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        withAnimation(.interactiveSpring(response: 0.15, dampingFraction: 0.86)) {
                            self.isDragging = true
                            let resistance: CGFloat = 0.4
                            self.dragOffset = CGSize(
                                width: gesture.translation.width * resistance,
                                height: gesture.translation.height * resistance
                            )
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.52)) {
                            self.isDragging = false
                            self.dragOffset = .zero
                        }
                    }
            )
            .onTapGesture {
                withAnimation(.interactiveSpring(response: 0.36, dampingFraction: 0.72)) {
                    isExpanded.toggle()
                }
            }
        }
        .animation(.interactiveSpring(response: 0.36, dampingFraction: 0.72), value: spotify.isPlaying)
        .animation(.interactiveSpring(response: 0.36, dampingFraction: 0.72), value: spotify.currentTrack)
        .animation(.interactiveSpring(response: 0.36, dampingFraction: 0.72), value: isExpanded)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}