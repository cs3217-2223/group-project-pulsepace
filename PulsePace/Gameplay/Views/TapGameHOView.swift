//
//  TapGameHOView.swift
//  PulsePace
//
//  Created by Charisma Kausar on 7/4/23.
//

import SwiftUI

struct TapGameHOView: View {
    @EnvironmentObject var viewModel: GameViewModel
    let tapGameHOVM: TapGameHOVM
    @State private var scale = 0.0
    @State private var isInteractedWith = false

    var body: some View {
        let tapGameHO = tapGameHOVM.gameHO
        let ringDiameter: CGFloat = min(800, max(100, 100 + 200 * tapGameHOVM.ringScale))
        let color = tapGameHOVM.fromPartner ? GameHOColors.fromPartnerColor :
            tapGameHOVM.isBomb ? GameHOColors.bombColor : GameHOColors.defaultColor
        let tappedColor = tapGameHOVM.isBomb ? GameHOColors.bombTappedColor :
            GameHOColors.interactedColor

        return ZStack {
            Circle()
                .strokeBorder(color, lineWidth: 4)
                .frame(width: ringDiameter + scale, height: ringDiameter + scale)
                .position(x: tapGameHO.position.x,
                          y: tapGameHO.position.y)

            Circle()
                .fill(isInteractedWith ? tappedColor : color)
                .frame(width: 100 + scale, height: 100 + scale)
                .position(x: tapGameHO.position.x,
                          y: tapGameHO.position.y)
        }
        .opacity(tapGameHOVM.opacity)
        .modifier(GestureModifier(input: TapInput(),
                                  command: TapCommand(receiver: tapGameHO,
                                                      eventManager: tapGameHOVM.eventManager,
                                                      timeReceived: viewModel.songPosition)))
        .modifier(GestureAnimation(input: TapInput()) {
            withAnimation(.easeInOut(duration: 0.1)) {
                scale = 15.0
                isInteractedWith = true
            }
        } onRelease: {
            withAnimation {
                scale = 0.0
                isInteractedWith = false
            }
        })
    }
}

struct SlideGameHOView: View {
    @EnvironmentObject var viewModel: GameViewModel
    let slideGameHOVM: SlideGameHOVM
    @State private var scale = 0.0
    @State private var isInteractedWith = false

    var body: some View {
        let slideGameHO = slideGameHOVM.gameHO
        let ringDiameter: CGFloat = min(800, max(100, 100 + 200 * slideGameHOVM.ringScale))
        let color = slideGameHOVM.fromPartner ? GameHOColors.fromPartnerColor : GameHOColors.defaultColor

        return ZStack {
            DrawShapeBorder(points: [slideGameHO.position] + slideGameHO.vertices).stroked(
                strokeColor: isInteractedWith ? GameHOColors.interactedColor :
                    GameHOColors.slideStrokeColor, strokeWidth: 100 + scale, borderWidth: 10
            )

            Circle()
                .strokeBorder(color, lineWidth: 4)
                .frame(width: ringDiameter + scale, height: ringDiameter + scale)
                .position(x: slideGameHO.position.x,
                          y: slideGameHO.position.y)

            Circle()
                .fill(color)
                .frame(width: 100 + scale, height: 100 + scale)
                .position(x: slideGameHO.expectedPosition.x,
                          y: slideGameHO.expectedPosition.y)

            if let lastVertex = slideGameHO.vertices.last {
                Circle()
                    .fill(GameHOColors.defaultColor)
                    .frame(width: 100 + scale, height: 100 + scale)
                    .position(x: lastVertex.x,
                              y: lastVertex.y)
            }

            ForEach(slideGameHO.vertices, id: \.self) { position in
                Circle()
                    .fill(color)
                    .frame(width: 20, height: 20)
                    .position(x: position.x,
                              y: position.y)
            }
        }
        .opacity(slideGameHOVM.opacity)
        .modifier(GestureModifier(input: SlideInput(),
                                  command: SlideCommand(receiver: slideGameHO,
                                                        eventManager: slideGameHOVM.eventManager,
                                                        timeReceived: viewModel.songPosition,
                                                        frame: viewModel.frame
                                                       )))
        .modifier(GestureAnimation(input: SlideInput()) {
            withAnimation(.easeInOut(duration: 0.1)) {
                scale = 15
                isInteractedWith = true
            }
        } onRelease: {
            withAnimation {
                scale = 0
                isInteractedWith = false
            }
        })
    }
}

struct HoldGameHOView: View {
    @EnvironmentObject var viewModel: GameViewModel
    let holdGameHOVM: HoldGameHOVM
    @State private var scale = 0.0
    @State private var isInteractedWith = false

    var body: some View {
        let holdGameHO = holdGameHOVM.gameHO
        let ringDiameter: CGFloat = min(800, max(100, 100 + 200 * holdGameHOVM.ringScale))
        let color = holdGameHOVM.fromPartner ? GameHOColors.fromPartnerColor : GameHOColors.defaultColor

        return ZStack {
            Circle()
                .strokeBorder(color, lineWidth: 4)
                .frame(width: ringDiameter + scale, height: ringDiameter + scale)
                .position(x: holdGameHO.position.x,
                          y: holdGameHO.position.y)

            Circle()
                .fill(isInteractedWith ? GameHOColors.interactedColor : color)
                .frame(width: 100 + scale, height: 100 + scale)
                .position(x: holdGameHO.position.x,
                          y: holdGameHO.position.y)
            CircularProgressView(progress: holdGameHOVM.progress)
                        .frame(width: 120 + scale, height: 120 + scale)
                        .position(x: holdGameHO.position.x,
                                  y: holdGameHO.position.y)

            Text("HOLD")
                .foregroundColor(GameHOColors.textColor)
                .font(Fonts.caption)
                .position(x: holdGameHO.position.x,
                          y: holdGameHO.position.y)
        }
        .opacity(holdGameHOVM.opacity)
        .modifier(GestureModifier(input: HoldInput(),
                                  command: HoldCommand(receiver: holdGameHO,
                                                       eventManager: holdGameHOVM.eventManager,
                                                       timeReceived: viewModel.songPosition)))
        .modifier(GestureAnimation(input: HoldInput()) {
            withAnimation(.easeInOut(duration: 0.1)) {
                scale = 15
                isInteractedWith = true
            }
        } onRelease: {
            withAnimation {
                scale = 1.00
                isInteractedWith = false
            }
        })
    }
}
struct CircularProgressView: View {
    let progress: Double
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    GameHOColors.holdStrokeColor,
                    lineWidth: 5
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    GameHOColors.holdProgressColor,
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )

                .rotationEffect(.degrees(-90))
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

enum GameHOColors {
    static let defaultColor = Color.white
    static let interactedColor = Color.purple
    static let fromPartnerColor = Color.orange
    static let bombColor = Color(hex: 0x646466)
    static let bombTappedColor = Color.red
    static let slideStrokeColor = Color.blue
    static let holdStrokeColor = Color.purple.opacity(0.5)
    static let holdProgressColor = Color.purple
    static let textColor = Color.gray
}
