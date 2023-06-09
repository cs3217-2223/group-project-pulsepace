//
//  MatchMessageDecoder.swift
//  PulsePace
//
//  Created by Charisma Kausar on 31/3/23.
//

import Foundation

final class MatchMessageDecoder: MessageHandler {
    static func createHandler() -> MatchMessageDecoder {
        MatchMessageDecoder()
    }

    typealias MatchEventType = PublishNoEvent
    var nextHandler: (any MessageHandler)?

    func addMessageToEventQueue(eventManager: EventManagable, message: MatchEventMessage) {
        nextHandler?.addMessageToEventQueue(eventManager: eventManager, message: message)
        return
    }
}

final class BombDisruptorMessageDecoder: MessageHandler {
    static func createHandler() -> BombDisruptorMessageDecoder {
        BombDisruptorMessageDecoder()
    }

    typealias MatchEventType = PublishBombDisruptorEvent
    var nextHandler: (any MessageHandler)?

    func addMessageToEventQueue(eventManager: EventManagable, message: MatchEventMessage) {
        guard let matchEvent = decodeMatchEventMessage(message: message) else {
            nextHandler?.addMessageToEventQueue(eventManager: eventManager, message: message)
            return
        }
        eventManager.add(event: SpawnBombDisruptorEvent(timestamp: Date().timeIntervalSince1970,
                                                        bombSourcePlayerId: message.sourceId,
                                                        bombTargetPlayerId: matchEvent.bombTargetId,
                                                        bombLocation: matchEvent.bombLocation))
    }
}

final class NoHintsDisruptorMessageDecoder: MessageHandler {
    static func createHandler() -> NoHintsDisruptorMessageDecoder {
        NoHintsDisruptorMessageDecoder()
    }

    typealias MatchEventType = PublishNoHintsDisruptorEvent
    var nextHandler: (any MessageHandler)?

    func addMessageToEventQueue(eventManager: EventManagable, message: MatchEventMessage) {
        guard let matchEvent = decodeMatchEventMessage(message: message) else {
            nextHandler?.addMessageToEventQueue(eventManager: eventManager, message: message)
            return
        }
        eventManager.add(event: ActivateNoHintsDisruptorEvent(timestamp: matchEvent.timestamp,
                                                              noHintsSourcePlayerId: message.sourceId,
                                                              noHintsTargetPlayerId: matchEvent.noHintsTargetId,
                                                              preSpawnInterval: matchEvent.preSpawnInterval,
                                                              duration: matchEvent.duration))
    }
}

final class MissTapMessageDecoder: MessageHandler {
    static func createHandler() -> MissTapMessageDecoder {
        MissTapMessageDecoder()
    }

    typealias MatchEventType = PublishMissTapEvent
    var nextHandler: (any MessageHandler)?

    func addMessageToEventQueue(eventManager: EventManagable, message: MatchEventMessage) {
        guard let matchEvent = decodeMatchEventMessage(message: message) else {
            nextHandler?.addMessageToEventQueue(eventManager: eventManager, message: message)
            return
        }

        // Spawned only on other player's device
        guard let userConfigManager = UserConfigManager.instance else {
            fatalError("No user config manager")
        }
        if matchEvent.sourceId == userConfigManager.userId {
            return
        }

        eventManager.add(event: SpawnHOEvent(timestamp: Date().timeIntervalSince1970,
                                             hitObject: matchEvent.tapHO.deserialize()))
    }
}

final class MissHoldMessageDecoder: MessageHandler {
    static func createHandler() -> MissHoldMessageDecoder {
        MissHoldMessageDecoder()
    }

    typealias MatchEventType = PublishMissHoldEvent
    var nextHandler: (any MessageHandler)?

    func addMessageToEventQueue(eventManager: EventManagable, message: MatchEventMessage) {
        guard let matchEvent = decodeMatchEventMessage(message: message) else {
            nextHandler?.addMessageToEventQueue(eventManager: eventManager, message: message)
            return
        }

        guard let userConfigManager = UserConfigManager.instance else {
            fatalError("No user config manager")
        }
        if matchEvent.sourceId == userConfigManager.userId {
            return
        }

        eventManager.add(event: SpawnHOEvent(
            timestamp: Date().timeIntervalSince1970,
            hitObject: matchEvent.holdHO.deserialize()
        ))
    }
}

final class MissSlideMessageDecoder: MessageHandler {
    static func createHandler() -> MissSlideMessageDecoder {
        MissSlideMessageDecoder()
    }

    typealias MatchEventType = PublishMissSlideEvent
    var nextHandler: (any MessageHandler)?

    func addMessageToEventQueue(eventManager: EventManagable, message: MatchEventMessage) {
        guard let matchEvent = decodeMatchEventMessage(message: message) else {
            nextHandler?.addMessageToEventQueue(eventManager: eventManager, message: message)
            return
        }

        guard let userConfigManager = UserConfigManager.instance else {
            fatalError("No user config manager")
        }
        if matchEvent.sourceId == userConfigManager.userId {
            return
        }

        eventManager.add(event: SpawnHOEvent(
            timestamp: Date().timeIntervalSince1970,
            hitObject: matchEvent.slideHO.deserialize()
        ))
    }
}

final class GameCompleteMessageDecoder: MessageHandler {
    static func createHandler() -> GameCompleteMessageDecoder {
        GameCompleteMessageDecoder()
    }

    typealias MatchEventType = PublishGameCompleteEvent
    var nextHandler: (any MessageHandler)?

    func addMessageToEventQueue(eventManager: EventManagable, message: MatchEventMessage) {
        guard let matchEvent = decodeMatchEventMessage(message: message) else {
            nextHandler?.addMessageToEventQueue(eventManager: eventManager, message: message)
            return
        }

        guard let userConfigManager = UserConfigManager.instance else {
            fatalError("No user config manager")
        }

        if matchEvent.sourceId == userConfigManager.userId {
            return
        }

        eventManager.add(event: GameCompleteEvent(timestamp: matchEvent.timestamp,
                                                  finalScore: matchEvent.finalScore))
    }
}

final class DeathMessageDecoder: MessageHandler {
    static func createHandler() -> DeathMessageDecoder {
        DeathMessageDecoder()
    }

    typealias MatchEventType = PublishDeathEvent
    var nextHandler: (any MessageHandler)?

    func addMessageToEventQueue(eventManager: EventManagable, message: MatchEventMessage) {
        guard let matchEvent = decodeMatchEventMessage(message: message) else {
            nextHandler?.addMessageToEventQueue(eventManager: eventManager, message: message)
            return
        }

        eventManager.add(event: DeathEvent(
            timestamp: Date().timeIntervalSince1970,
            diedPlayerId: matchEvent.diedPlayerId
        ))
    }
}

final class ScoreMessageDecoder: MessageHandler {
    static func createHandler() -> ScoreMessageDecoder {
        ScoreMessageDecoder()
    }

    typealias MatchEventType = PublishScoreEvent
    var nextHandler: (any MessageHandler)?

    func addMessageToEventQueue(eventManager: EventManagable, message: MatchEventMessage) {
        guard let matchEvent = decodeMatchEventMessage(message: message) else {
            nextHandler?.addMessageToEventQueue(eventManager: eventManager, message: message)
            return
        }

        eventManager.add(event: UpdateScoreEvent(
            timestamp: Date().timeIntervalSince1970,
            playerScore: matchEvent.playerScore,
            playerId: message.sourceId
        ))
    }
}
