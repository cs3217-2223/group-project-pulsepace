//
//  SpinCommand.swift
//  PulsePace
//
//  Created by Charisma Kausar on 9/3/23.
//

class SpinCommand: Command {
    convenience init() {
        self.init { _ in
            print("Spin")
        }
    }
}
