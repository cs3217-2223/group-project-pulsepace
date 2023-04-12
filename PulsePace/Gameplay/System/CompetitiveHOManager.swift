//
//  CompetitiveHOManager.swift
//  PulsePace
//
//  Created by Charisma Kausar on 2/4/23.
//

import Foundation

class CompetitiveHOManager: HitObjectManager {
    private var disruptorsQueue = MyQueue<TapHitObject>()

    override func reset() {
        super.reset()
        disruptorsQueue.removeAll()
    }

    override func registerEventHandlers(eventManager: EventManagable) {
        super.registerEventHandlers(eventManager: eventManager)
        eventManager.registerHandler(onSpawnBombHandler)
        eventManager.registerHandler(onActivateNoHintsHandler)
    }

    lazy var onSpawnBombHandler
    = { [weak self] (_: EventManagable, event: SpawnBombDisruptorEvent) -> Void in
        guard let userConfigManager = UserConfigManager.instance else {
            fatalError("No user config manager")
        }

        guard event.bombTargetPlayerId == userConfigManager.userId else {
            return
        }
        self?.disruptorsQueue.enqueue(TapHitObject(
            position: event.bombLocation, startTime: Date().timeIntervalSince1970))
    }

    lazy var onActivateNoHintsHandler
    = { [weak self] (eventManager: EventManagable, event: ActivateNoHintsDisruptorEvent) -> Void in
        guard let userConfigManager = UserConfigManager.instance else {
            fatalError("No user config manager")
        }

        guard event.noHintsTargetPlayerId == userConfigManager.userId else {
            return
        }
        let originalPreSpawnInterval = self?.preSpawnInterval
        self?.preSpawnInterval = event.preSpawnInterval
        DispatchQueue.main.asyncAfter(deadline: .now() + event.duration) {
            self?.preSpawnInterval = originalPreSpawnInterval ?? 0.0
            eventManager.add(event: DeactivateNoHintsDisruptorEvent(timestamp: Date().timeIntervalSince1970,
                                                                    noHintsTargetPlayerId: event.noHintsTargetPlayerId))
        }
    }

    override func checkBeatMap(_ currBeat: Double) -> [any GameHO] {
        var gameHOSpawned = super.checkBeatMap(currBeat)
        while let disruptorHO = disruptorsQueue.peek() {
            disruptorHO.startTime = ceil(currBeat)
            guard let gameHO = spawnGameHitObject(disruptorHO) as? TapGameHO else {
                continue
            }
            gameHO.isBomb = true
            gameHOSpawned.append(gameHO)
            _ = disruptorsQueue.dequeue()
        }

        return gameHOSpawned
    }
}
