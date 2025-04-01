//
//  MockDataService.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import Foundation

class MockDataService {
    // Singleton instance
    static let shared = MockDataService()
    private init() {}
    
    // MARK: - User Data
    func getMockUser() -> User {
        return User.example
    }
    
    func getMockFamilyMembers() -> [FamilyMember] {
        return [
            FamilyMember.example,
            FamilyMember(
                relationship: "Parent",
                firstName: "Robert",
                lastName: "Doe",
                dateOfBirth: Date(timeIntervalSince1970: 4360025600), // Example date
                healthConditions: ["Hypertension", "High Cholesterol"],
                allergies: ["Shellfish"]
            ),
            FamilyMember(
                relationship: "Spouse",
                firstName: "Sarah",
                lastName: "Doe",
                dateOfBirth: Date(timeIntervalSince1970: 6897025600), // Example date
                healthConditions: ["Asthma"],
                allergies: ["Pollen", "Dust"]
            )
        ]
    }
    
    // MARK: - Prescription Data
    func getMockPrescriptions() -> [Prescription] {
        let now = Date()
        
        var examplePrescription = Prescription.example
        
        var prescription2 = examplePrescription
        prescription2.id = UUID().uuidString
        prescription2.rxNumber = "RX789012"
        prescription2.medicationName = "Lisinopril"
        prescription2.status = .readyForPickup
        prescription2.statusHistory = [
            StatusUpdate(status: .requestReceived, timestamp: now.addingTimeInterval(-86400 * 5)),
            StatusUpdate(status: .entered, timestamp: now.addingTimeInterval(-86400 * 4)),
            StatusUpdate(status: .pharmacistCheck, timestamp: now.addingTimeInterval(-86400 * 3)),
            StatusUpdate(status: .prepPackaging, timestamp: now.addingTimeInterval(-86400 * 2)),
            StatusUpdate(status: .billing, timestamp: now.addingTimeInterval(-86400 * 1)),
            StatusUpdate(status: .readyForPickup, timestamp: now)
        ]
        
        var prescription3 = examplePrescription
        prescription3.id = UUID().uuidString
        prescription3.rxNumber = "RX456789"
        prescription3.medicationName = "Atorvastatin"
        prescription3.status = .requestReceived
        prescription3.statusHistory = [
            StatusUpdate(status: .requestReceived, timestamp: now.addingTimeInterval(-3600 * 2))
        ]
        
        var prescription4 = examplePrescription
        prescription4.id = UUID().uuidString
        prescription4.rxNumber = "RX123890"
        prescription4.medicationName = "Amoxicillin"
        prescription4.status = .pharmacistCheck
        prescription4.pharmacistMessage = "We've identified a potential interaction with your current medications. We're contacting your doctor to confirm this prescription."
        prescription4.statusHistory = [
            StatusUpdate(status: .requestReceived, timestamp: now.addingTimeInterval(-86400 * 1.5)),
            StatusUpdate(status: .entered, timestamp: now.addingTimeInterval(-86400 * 1)),
            StatusUpdate(status: .pharmacistCheck, timestamp: now.addingTimeInterval(-3600 * 5))
        ]
        
        // Add family member prescription
        var prescription5 = examplePrescription
        prescription5.id = UUID().uuidString
        prescription5.rxNumber = "RX567123"
        prescription5.medicationName = "Albuterol Inhaler"
        prescription5.status = .completed
        prescription5.forUser = "family001"
        prescription5.forUserName = "Emma Doe"
        prescription5.statusHistory = [
            StatusUpdate(status: .requestReceived, timestamp: now.addingTimeInterval(-86400 * 10)),
            StatusUpdate(status: .entered, timestamp: now.addingTimeInterval(-86400 * 9)),
            StatusUpdate(status: .pharmacistCheck, timestamp: now.addingTimeInterval(-86400 * 9)),
            StatusUpdate(status: .prepPackaging, timestamp: now.addingTimeInterval(-86400 * 8)),
            StatusUpdate(status: .billing, timestamp: now.addingTimeInterval(-86400 * 8)),
            StatusUpdate(status: .readyForPickup, timestamp: now.addingTimeInterval(-86400 * 7)),
            StatusUpdate(status: .completed, timestamp: now.addingTimeInterval(-86400 * 6))
        ]
        
        return [examplePrescription, prescription2, prescription3, prescription4, prescription5]
    }
    
    // MARK: - Notification Data
    func getMockNotifications() -> [AppNotification] {
        return AppNotification.examples
    }
    
    // MARK: - Gamification Data
    func getMockBadges() -> [Badge] {
        return Badge.examples
    }
    
    func getMockHealthInfo() -> [HealthInfo] {
        return HealthInfo.examples
    }
    
    func getMockAdherenceData() -> [String: Double] {
        return [
            "Monday": 85,
            "Tuesday": 100,
            "Wednesday": 75,
            "Thursday": 90,
            "Friday": 100,
            "Saturday": 80,
            "Sunday": 95
        ]
    }
    
    // MARK: - Minigame Data
    func getMockMinigames() -> [Minigame] {
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
    
    // MARK: - Miscellaneous Helper Methods
    func generateRandomAdherenceScore() -> Int {
        return Int.random(in: 60...100)
    }
    
    func generateRandomNotification() -> AppNotification {
        let notificationTypes: [NotificationType] = [.requestReceived, .prepPackaging, .readyForPickup, .pharmacistMessage, .adherenceReminder, .healthInfo, .badge]
        let randomType = notificationTypes.randomElement() ?? .info
        
        let titles = [
            "New Prescription Update",
            "Medication Alert",
            "Health Badge Earned",
            "Refill Reminder",
            "Health Tip Available"
        ]
        
        let messages = [
            "Your prescription status has been updated.",
            "Don't forget to take your medication today.",
            "You've earned a new health badge!",
            "One of your prescriptions is eligible for refill.",
            "Check out our latest health information article."
        ]
        
        return AppNotification(
            type: randomType,
            title: titles.randomElement() ?? "Notification",
            message: messages.randomElement() ?? "You have a new notification.",
            timestamp: Date()
        )
    }
}
