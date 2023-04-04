//
//  MatchEvent.swift
//  PulsePace
//
//  Created by Charisma Kausar on 31/3/23.
//

import Foundation

// NOTE: Assumes one to one relationship between match event and handler
protocol MatchEvent: Codable {
    associatedtype MessageHandlerType: MessageHandler
    var timestamp: Double { get }
}

extension MatchEvent {
    static var getType: MessageHandlerType.Type {
        MessageHandlerType.self
    }
}

// Not used for base decoder dummy
struct PublishNoEvent: MatchEvent {
    typealias MessageHandlerType = MatchMessageDecoder
    var timestamp: Double
}

// Coop limited to two player
struct PublishMissTapEvent: MatchEvent {
    typealias MessageHandlerType = MissTapMessageDecoder
    var timestamp: Double
    var tapHO: SerializedTapHO
    var sourceId: String
}

struct PublishMissSlideEvent: MatchEvent {
    typealias MessageHandlerType = MissSlideMessageDecoder
    var timestamp: Double
    var slideHO: SerializedSlideHO
    var sourceId: String
}

struct PublishMissHoldEvent: MatchEvent {
    typealias MessageHandlerType = MissHoldMessageDecoder
    var timestamp: Double
    var holdHO: SerializedHoldHO
    var sourceId: String
}

struct PublishBombDisruptorEvent: MatchEvent {
    typealias MessageHandlerType = BombDisruptorMessageDecoder
    var timestamp: Double
    var bombTargetId: String
    var bombLocation: CGPoint
}

struct PublishNoHintsDisruptorEvent: MatchEvent {
    typealias MessageHandlerType = NoHintsDisruptorMessageDecoder
    var timestamp: Double
    var noHintsTargetId: String
    var preSpawnInterval: Double
    var duration: Double
}

struct PublishDeathEvent: MatchEvent {
    typealias MessageHandlerType = DeathMessageDecoder
    var timestamp: Double
    var diedPlayerId: String
}

// Events
struct SpawnBombDisruptorEvent: Event {
    var timestamp: Double
    var bombSourcePlayerId: String
    var bombTargetPlayerId: String
    var bombLocation: CGPoint
}

struct ActivateNoHintsDisruptorEvent: Event {
    var timestamp: Double
    var noHintsSourcePlayerId: String
    var noHintsTargetPlayerId: String
    var preSpawnInterval: Double
    var duration: Double
}

struct DeactivateNoHintsDisruptorEvent: Event {
    var timestamp: Double
    var noHintsTargetPlayerId: String
}

struct UpdateComboEvent: Event {
    var timestamp: Double
    var comboCount: Int
    var lastLocation: CGPoint
}

struct SpawnHOEvent: Event {
    var timestamp = 0.0
    var hitObject: any HitObject
}

struct DeathEvent: Event {
    var timestamp: Double
    var diedPlayerId: String
}

struct LostLifeEvent: Event {
    var timestamp: Double
    var lostLifePlayerId: String
}