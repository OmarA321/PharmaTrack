import Foundation

struct Badge: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var description: String
    var imageName: String
    var dateEarned: Date
    var category: BadgeCategory
    var points: Int
    var isUnlocked: Bool = false
    
    enum BadgeCategory: String, Codable {
        case adherence = "Medication Adherence"
        case vaccine = "Vaccination"
        case medsCheck = "Medication Review"
        case healthInfo = "Health Information"
        case activity = "App Activity"
    }
    
    static var examples: [Badge] {
        let now = Date()
        return [
            Badge(
                title: "Perfect Adherence",
                description: "Maintained 100% medication adherence for 30 days",
                imageName: "badge_adherence_star",
                dateEarned: now.addingTimeInterval(-86400 * 15),
                category: .adherence,
                points: 100,
                isUnlocked: false
            ),
            Badge(
                title: "Flu Fighter",
                description: "Received your annual flu vaccination",
                imageName: "badge_vaccine_flu",
                dateEarned: now.addingTimeInterval(-86400 * 45),
                category: .vaccine,
                points: 75,
                isUnlocked: false
            ),
            Badge(
                title: "Health Scholar",
                description: "Read 5 health information articles",
                imageName: "badge_health_info",
                dateEarned: now.addingTimeInterval(-86400 * 10),
                category: .healthInfo,
                points: 50,
                isUnlocked: false
            ),
            Badge(
                title: "Medication Master",
                description: "Completed a comprehensive medication review",
                imageName: "badge_meds_check",
                dateEarned: now.addingTimeInterval(-86400 * 30),
                category: .medsCheck,
                points: 125,
                isUnlocked: false
            ),
            Badge(
                title: "Family Caretaker",
                description: "Added and managed family members' medications",
                imageName: "badge_family_care",
                dateEarned: now.addingTimeInterval(-86400 * 5),
                category: .activity,
                points: 75,
                isUnlocked: false
            )
        ]
    }
}
