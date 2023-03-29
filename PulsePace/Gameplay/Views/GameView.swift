//
//  GameView.swift
//  PulsePace
//
//  Created by Charisma Kausar on 9/3/23.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @EnvironmentObject var audioManager: AudioManager

    var body: some View {
        ZStack(alignment: .top) {
            GameplayAreaView()
            .overlay(alignment: .topTrailing) {
                ScoreView()
                    .ignoresSafeArea()
            }
            .overlay(alignment: .bottomTrailing) {
                GameControlView()
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .onAppear {
            audioManager.startPlayer(track: "test")
            viewModel.startGameplay()
            if let audioPlayer = audioManager.player {
                viewModel.initialisePlayer(audioPlayer: audioPlayer)
            }
        }
        .onDisappear {
            audioManager.stopPlayer()
            viewModel.stopGameplay()
        }
        .environmentObject(viewModel)
        .fullBackground(imageName: viewModel.gameBackground)
    }
}

struct TapGameHOView: View {
    @EnvironmentObject var viewModel: GameViewModel
    let tapGameHOVM: TapGameHOVM

    var body: some View {
        let tapGameHO = tapGameHOVM.gameHO
        let ringDiameter: CGFloat = min(800, max(100, 100 + 200 * tapGameHOVM.ringScale))

        return ZStack {
            Circle()
                .strokeBorder(.white, lineWidth: 4)
                .frame(width: ringDiameter, height: ringDiameter)
                .position(x: tapGameHO.position.x,
                          y: tapGameHO.position.y)

            Circle()
                .fill(.white)
                .frame(width: 100, height: 100)
                .position(x: tapGameHO.position.x,
                          y: tapGameHO.position.y)
        }
        .opacity(tapGameHOVM.opacity)
        .modifier(GestureModifier(input: TapInput(),
                                  command: TapCommand(receiver: tapGameHO,
                                                      timeReceived: viewModel.songPosition)))
    }
}

struct SlideGameHOView: View {
    @EnvironmentObject var viewModel: GameViewModel
    let slideGameHOVM: SlideGameHOVM

    var body: some View {
        let slideGameHO = slideGameHOVM.gameHO
        let ringDiameter: CGFloat = min(800, max(100, 100 + 200 * slideGameHOVM.ringScale))

        return ZStack {
            DrawShapeBorder(points: [slideGameHO.position] + slideGameHO.vertices).stroked(
                strokeColor: .blue, strokeWidth: 100, borderWidth: 10
            )

            Circle()
                .strokeBorder(.white, lineWidth: 4)
                .frame(width: ringDiameter, height: ringDiameter)
                .position(x: slideGameHO.position.x,
                          y: slideGameHO.position.y)

            Circle()
                .fill(.white)
                .frame(width: 100, height: 100)
                .position(x: slideGameHO.expectedPosition.x,
                          y: slideGameHO.expectedPosition.y)

            if let lastVertex = slideGameHO.vertices.last {
                Circle()
                    .fill(.white)
                    .frame(width: 100, height: 100)
                    .position(x: lastVertex.x,
                              y: lastVertex.y)
            }

            ForEach(slideGameHO.vertices, id: \.self) { position in
                Circle()
                    .fill(.white)
                    .frame(width: 20, height: 20)
                    .position(x: position.x,
                              y: position.y)
            }
        }
        .opacity(slideGameHOVM.opacity)
        .modifier(GestureModifier(input: SlideInput(),
                                  command: SlideCommand(receiver: slideGameHO,
                                                        timeReceived: viewModel.songPosition)))
    }
}

struct HoldGameHOView: View {
    @EnvironmentObject var viewModel: GameViewModel
    let holdGameHOVM: HoldGameHOVM

    var body: some View {
        let holdGameHO = holdGameHOVM.gameHO
        let ringDiameter: CGFloat = min(800, max(100, 100 + 200 * holdGameHOVM.ringScale))

        return ZStack {
            Circle()
                .strokeBorder(.white, lineWidth: 4)
                .frame(width: ringDiameter, height: ringDiameter)
                .position(x: holdGameHO.position.x,
                          y: holdGameHO.position.y)

            Circle()
                .fill(.white)
                .frame(width: 100, height: 100)
                .position(x: holdGameHO.position.x,
                          y: holdGameHO.position.y)
        }
        .opacity(holdGameHOVM.opacity)
        .modifier(GestureModifier(input: HoldInput(),
                                  command: HoldCommand(receiver: holdGameHO,
                                                       timeReceived: viewModel.songPosition)))
    }
}
