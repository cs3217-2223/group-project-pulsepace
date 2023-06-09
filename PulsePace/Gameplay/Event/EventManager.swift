//
//  EventManager.swift
//  PulsePace
//
//  Created by Yuanxi Zhu on 26/3/23.
//

import Foundation

class EventManager: EventManagable, ObservableObject {
    var eventHandlerMap: [String: [EventHandler]] = [:]
    var eventQueue = PriorityQueue<Event> { a, b in
        a.timestamp < b.timestamp
    }

    weak var matchEventHandler: MatchEventHandler?

    func add(event: Event) {
        eventQueue.enqueue(event)
    }

    func registerHandler<T: Event>(_ handler: @escaping (EventManagable, T) -> Void) {
        let eventHandler = EventHandler(closure: handler, event: T.self)
        eventHandlerMap[T.label, default: []].append(eventHandler)
    }

    func handleAllEvents() {
        while !eventQueue.isEmpty {
            guard let event = eventQueue.dequeue(), let handlers = eventHandlerMap[type(of: event).label] else {
                return
            }
            handlers.forEach({ $0.execute(eventManager: self, event: event) })
        }
    }

    func setMatchEventHandler(matchEventHandler: MatchEventHandler) {
        self.matchEventHandler = matchEventHandler
        matchEventHandler.subscribeMatchEvents()
    }
}
