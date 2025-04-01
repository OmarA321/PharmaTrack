//
//  GamificationViewModel.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import Foundation
import Combine

class GamificationViewModel: ObservableObject {
    @Published var badges: [Badge] = []
    @Published var healthInfos: [HealthInfo] = []
    @Published var adherenceScore: Int = 0
    @Published var totalPoints: Int = 0
    
    // For minigames
    @Published var minigamesPlayed: Int = 0
    @Published var minigamesWon: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load mock data for prototype
        loadMockData()
        calculateTotalPoints()
    }
    
    private func loadMockData() {
        // In a real app, this would fetch from a server
        self.badges = Badge.examples
        self.healthInfos = HealthInfo.examples
        self.adherenceScore = 85
        self.minigamesPlayed = 5
        self.minigamesWon = 3
    }
    
    private func calculateTotalPoints() {
        totalPoints = badges.reduce(0) { $0 + $1.points } + (adherenceScore / 2)
    }
    
    func earnBadge(badge: Badge) -> Bool {
        // Check if the badge already exists
        if !badges.contains(where: { $0.id == badge.id }) {
            badges.append(badge)
            calculateTotalPoints()
            return true
        }
        return false
    }
    
    func checkAndAwardBadge(for category: Badge.BadgeCategory) -> Badge? {
        // Logic to check if a badge should be awarded based on user activity
        // This would be more sophisticated in a real app
        
        let now = Date()
        
        // For prototype, create a simple badge based on category
        switch category {
        case .adherence:
            if adherenceScore >= 90 {
                let badge = Badge(
                    title: "Adherence Champion",
                    description: "Maintained over 90% medication adherence",
                    imageName: "badge_adherence_champion",
                    dateEarned: now,
                    category: .adherence,
                    points: 150
                )
                if earnBadge(badge: badge) {
                    return badge
                }
            }
        case .healthInfo:
            let readCount = healthInfos.filter { $0.isRead }.count
            if readCount >= 3 {
                let badge = Badge(
                    title: "Health Enthusiast",
                    description: "Read 3+ health information articles",
                    imageName: "badge_health_enthusiast",
                    dateEarned: now,
                    category: .healthInfo,
                    points: 75
                )
                if earnBadge(badge: badge) {
                    return badge
                }
            }
        case .activity:
            if minigamesPlayed >= 5 {
                let badge = Badge(
                    title: "Game Master",
                    description: "Played 5+ health minigames",
                    imageName: "badge_game_master",
                    dateEarned: now,
                    category: .activity,
                    points: 50
                )
                if earnBadge(badge: badge) {
                    return badge
                }
            }
        default:
            return nil
        }
        return nil
    }
    
    func updateAdherenceScore(newScore: Int) {
        adherenceScore = newScore
        calculateTotalPoints()
        
        // Check if adherence badge should be awarded
        _ = checkAndAwardBadge(for: .adherence)
    }
    
    func markHealthInfoAsRead(_ healthInfoId: String) {
        if let index = healthInfos.firstIndex(where: { $0.id == healthInfoId }) {
            healthInfos[index].isRead = true
            healthInfos[index].readDate = Date()
            
            // Check if health info badge should be awarded
            _ = checkAndAwardBadge(for: .healthInfo)
        }
    }
    
    func recordMinigamePlay(won: Bool) {
        minigamesPlayed += 1
        if won {
            minigamesWon += 1
        }
        
        // Check if activity badge should be awarded
        _ = checkAndAwardBadge(for: .activity)
    }
    
    func getAdherenceLevel() -> String {
        if adherenceScore >= 90 {
            return "Excellent"
        } else if adherenceScore >= 75 {
            return "Good"
        } else if adherenceScore >= 60 {
            return "Fair"
        } else {
            return "Needs Improvement"
        }
    }
    
    func getUserLevel() -> (level: Int, progress: Double) {
        // Calculate user level based on total points
        let pointsPerLevel = 100
        let level = (totalPoints / pointsPerLevel) + 1
        let progress = Double(totalPoints % pointsPerLevel) / Double(pointsPerLevel)
        return (level, progress)
    }
}
