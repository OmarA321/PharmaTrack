//
//  Minigame.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import Foundation
import Foundation

struct Minigame: Identifiable {
    let id: String
    let name: String
    let description: String
    let difficultyLevel: String
    let timeToPlay: String
    let pointsToEarn: Int
    let imageName: String
    
    // Sample data for preview and testing
    static var examples: [Minigame] {
        return [
            Minigame(
                id: "game1",
                name: "Med Match",
                description: "Match medications with their purposes. Learn about different medications while having fun!",
                difficultyLevel: "Easy",
                timeToPlay: "2-3 min",
                pointsToEarn: 50,
                imageName: "game_match"
            ),
            Minigame(
                id: "game2",
                name: "Pill Pursuit",
                description: "Race to collect your medications on time while avoiding obstacles. This game helps reinforce the importance of medication timing.",
                difficultyLevel: "Medium",
                timeToPlay: "3-5 min",
                pointsToEarn: 75,
                imageName: "game_pursuit"
            ),
            Minigame(
                id: "game3",
                name: "Health Quiz",
                description: "Test your health knowledge with questions about medications, conditions, and general wellness.",
                difficultyLevel: "Hard",
                timeToPlay: "5-7 min",
                pointsToEarn: 100,
                imageName: "game_quiz"
            ),
            Minigame(
                id: "game4",
                name: "Body Explorer",
                description: "Learn how medications work in the body with this interactive educational game.",
                difficultyLevel: "Medium",
                timeToPlay: "4-6 min",
                pointsToEarn: 75,
                imageName: "game_explorer"
            )
        ]
    }
}
