//
//  MatchEventRelay.swift
//  PulsePace
//
//  Created by James Chiu on 2/4/23.
//

import Foundation

protocol MatchEventRelay: ModeSystem {
    var match: Match? { get set }
    var userId: String { get }
    var publisher: ((MatchEventMessage) -> Void)? { get set }
}

extension MatchEventRelay {
    func assignProperties(publisher: @escaping (MatchEventMessage) -> Void, match: Match) {
        self.match = match
        self.publisher = publisher
    }

    func reset() {
        match = nil
        publisher = nil
    }
}

class CoopMatchEventRelay: MatchEventRelay {
    var match: Match?
    let userId: String
    var publisher: ((MatchEventMessage) -> Void)?

    init() {
        guard let userConfigManager = UserConfigManager.instance else {
            fatalError("No user config manager")
        }

        self.userId = userConfigManager.userId
    }

    func registerEventHandlers(eventManager: EventManagable) {
        eventManager.registerHandler(missEventRelay)
        eventManager.registerHandler(gameCompleteEventRelay)
    }

    private lazy var missEventRelay = { [weak self] (_: EventManagable, missEvent: MissEvent) -> Void in
        guard let self = self else {
            fatalError("No active match event relay")
        }
        guard let matchEventMessage = MissEvent.makeMessage(event: missEvent, playerId: self.userId) else {
            return
        }
        self.publisher?(matchEventMessage)
    }

    private lazy var gameCompleteEventRelay
    = { [weak self] (_: EventManagable, gameCompleteEvent: GameCompleteEvent) -> Void in
        guard let self = self else {
            fatalError("No active match event relay")
        }

        guard let matchEventMessage = GameCompleteEvent
            .makeMessage(event: gameCompleteEvent, playerId: self.userId) else {
            return
        }
        self.publisher?(matchEventMessage)
    }
}

class CompetitiveMatchEventRelay: MatchEventRelay {
    var match: Match?
    let userId: String
    var publisher: ((MatchEventMessage) -> Void)?

    init() {
        guard let userConfigManager = UserConfigManager.instance else {
            fatalError("No user config manager")
        }
        self.userId = userConfigManager.userId
    }

    func registerEventHandlers(eventManager: EventManagable) {
        eventManager.registerHandler(selfDeathEventRelay)
    }

    private lazy var selfDeathEventRelay = { [weak self] (_: EventManagable, event: SelfDeathEvent) -> Void in
        guard let self = self else {
            fatalError("No active match event relay")
        }
        guard let matchEventMessage = SelfDeathEvent.makeMessage(event: event, playerId: self.userId) else {
            return
        }
        self.publisher?(matchEventMessage)
    }
}
