//
//  PlaybackControlView.swift
//  PulsePace
//
//  Created by Peter Jung on 2023/03/15.
//

import SwiftUI

struct PlaybackControlView: View {
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var beatmapDesigner: BeatmapDesignerViewModel

    var body: some View {
        HStack(spacing: 16) {
            renderPlaybackProgressSlider()
            renderPlaybackButtons()
            renderPlaybackRateButtons()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    .black.opacity(0.25),
                    .black.opacity(0.225)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    @ViewBuilder
    private func renderPlaybackProgressSlider() -> some View {
        if let player = audioManager.player {
            HStack(spacing: 10) {
                Text(DateComponentsFormatter.positional.string(from: player.currentTime) ?? "0:00")
                    .foregroundColor(.white)
                    .font(.system(size: 18))
                    .frame(width: 60)

                Slider(value: $beatmapDesigner.sliderValue, in: 0...player.duration) { editing in
                    beatmapDesigner.isEditing = editing
                    if editing {
                        player.pause()
                    } else {
                        player.currentTime = beatmapDesigner.sliderValue
                    }
                }
                .tint(.purple)
            }
        }
    }

    @ViewBuilder
    private func renderPlaybackButtons() -> some View {
        if let player = audioManager.player {
            HStack {
                let iconSystemName = player.isPlaying ? "pause.circle.fill" : "play.circle.fill"
                SystemIconButtonView(systemName: iconSystemName, fontSize: 44, color: .white) {
                    audioManager.togglePlayer()
                }
            }
        }
    }

    @ViewBuilder
    private func renderPlaybackRateButtons() -> some View {
        VStack(spacing: 8) {
            Text("Playback Rate")
                .foregroundColor(.white)

            HStack {
                SystemIconButtonView(systemName: "tortoise.fill", fontSize: 24, color: .white) {
                    audioManager.decreasePlaybackRate()
                }
                SystemIconButtonView(systemName: "hare.fill", fontSize: 24, color: .white) {
                    audioManager.increasePlaybackRate()
                }
            }
        }
    }
}

struct PlaybackControlView_Previews: PreviewProvider {
    static var previews: some View {
        PlaybackControlView()
    }
}
