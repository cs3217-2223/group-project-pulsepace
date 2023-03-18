//
//  GameViewModel.swift
//  PulsePace
//
//  Created by Charisma Kausar on 16/3/23.
//

import Foundation
import QuartzCore
import AVKit

protocol RenderSystem {
    var sceneAdaptor: ([Entity: any GameHO]) -> Void { get }
}

class GameViewModel: ObservableObject, RenderSystem {
    private var displayLink: CADisplayLink?
    private var gameEngine: GameEngine?
    @Published var slideGameHOs: [SlideGameHOVM] = []
    @Published var holdGameHOs: [HoldGameHOVM] = []
    @Published var tapGameHOs: [TapGameHOVM] = []
    var score: String {
        String(format: "%06d", 71_143)
    }

    var accuracy: String {
        String(Double(round(100 * 82.3883) / 100)) + "%"
    }

    var combo: String {
        String(14) + "x"
    }

    var health: Double {
        50
    }

    lazy var sceneAdaptor: ([Entity: any GameHO]) -> Void = { [weak self] gameHOTable in
        self?.clear()
        gameHOTable.forEach { gameHOEntity in
            if let slideGameHO = gameHOEntity.value as? SlideGameHO {
                self?.slideGameHOs.append(SlideGameHOVM(gameHO: slideGameHO, id: gameHOEntity.key.id))
            } else if let holdGameHO = gameHOEntity.value as? HoldGameHO {
                self?.holdGameHOs.append(HoldGameHOVM(gameHO: holdGameHO, id: gameHOEntity.key.id))
            } else if let tapGameHO = gameHOEntity.value as? TapGameHO {
                self?.tapGameHOs.append(TapGameHOVM(gameHO: tapGameHO, id: gameHOEntity.key.id))
            } else {
                print("Unidentified game HO type")
            }
        }
    }

    private func clear() {
        slideGameHOs.removeAll()
        holdGameHOs.removeAll()
        tapGameHOs.removeAll()
    }

    var gameBackground: String {
        "game-background"
    }

    @objc func step() {
        guard let displayLink = displayLink else {
            print("No active display link")
            return
        }

        guard let gameEngine = gameEngine else {
            print("No game engine running")
            return
        }

        let deltaTime = displayLink.targetTimestamp - displayLink.timestamp

        gameEngine.step(deltaTime)
        sceneAdaptor(gameEngine.gameHOTable)
    }

    func initEngineWithBeatmap(_ beatmap: Beatmap) {
        gameEngine = GameEngine()
        gameEngine?.load(beatmap)
    }

    func startGameplay() {
        createDisplayLink()
    }

    func stopGameplay() {
        displayLink?.invalidate()
    }

    private func createDisplayLink() {
        self.displayLink = CADisplayLink(target: self, selector: #selector(step))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 75, maximum: 150, __preferred: 90)
        displayLink?.add(to: .current, forMode: .default)
    }

}
