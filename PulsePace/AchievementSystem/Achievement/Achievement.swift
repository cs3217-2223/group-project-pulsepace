//
//  Achievement.swift
//  PulsePace
//
//  Created by Peter Jung on 2023/03/26.
//

import Foundation

// TODO: property storage type as T
protocol Achievement: AnyObject {
    var title: String { get }
    var description: String { get }
    var imageName: String { get }
    var propertyStorage: PropertyStorage? { get set }
    var isUnlocked: Bool { get set }
    var areConstraintsSatisfied: Bool { get }
    var progress: Double { get }
    var delegate: AchievementUpdateDelegate? { get set }
}

extension Achievement {
    func updateProgress() {
        guard !isUnlocked, areConstraintsSatisfied else {
            return
        }
        isUnlocked = true
        delegate?.notifyUnlockedAchievement(self)
        print("Unlocked \(title)")
    }
}
