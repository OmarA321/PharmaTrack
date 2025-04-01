//
//  Notification.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import Foundation

import Foundation

enum NotificationType: String, Codable {
    case requestReceived = "Request Received"
    case prepPackaging = "Prep & Packaging"
    case readyForPickup = "Ready for Pickup"
    case pharmacistMessage = "Pharmacist Message"
    case adherenceReminder = "Medication Reminder"
    case healthInfo = "Health Information"
    case badge = "New Badge"
    case info = "Information"  // Added this case
}

struct AppNotification: Identifiable, Codable {
    var id: String = UUID().uuidString
    var type: NotificationType
    var title: String
    var message: String
    var timestamp: Date
    var isRead: Bool = false
    var prescriptionId: String?
    var actionUrl: String?
    
    // For gamification
    var relatedBadgeId: String?
    var relatedHealthInfoId: String?
    
    static var examples: [AppNotification] {
        let now = Date()
        return [
            AppNotification(
                type: .requestReceived,
                title: "Prescription Request Received",
                message: "Your refill request for Metformin has been received",
                timestamp: now.addingTimeInterval(-3600 * 5),
                prescriptionId: "RX123456"
            ),
            AppNotification(
                type: .prepPackaging,
                title: "Prescription Being Prepared",
                message: "Your prescription for Lisinopril is being prepared",
                timestamp: now.addingTimeInterval(-3600 * 3),
                prescriptionId: "RX789012"
            ),
            AppNotification(
                type: .readyForPickup,
                title: "Ready for Pickup",
                message: "Your prescription for Atorvastatin is ready for pickup",
                timestamp: now.addingTimeInterval(-3600 * 1),
                prescriptionId: "RX456789"
            ),
            AppNotification(
                type: .pharmacistMessage,
                title: "Message from Pharmacist",
                message: "We've identified a potential interaction with your new medication. Please contact us.",
                timestamp: now.addingTimeInterval(-3600 * 0.5),
                prescriptionId: "RX123890"
            ),
            AppNotification(
                type: .badge,
                title: "New Badge Earned!",
                message: "Congratulations! You've earned the 'Medication Master' badge for perfect adherence.",
                timestamp: now.addingTimeInterval(-3600 * 2),
                relatedBadgeId: "badge001"
            ),
            AppNotification(
                type: .healthInfo,
                title: "Health Tip Available",
                message: "Learn about managing blood pressure with today's health tip!",
                timestamp: now.addingTimeInterval(-3600 * 4),
                relatedHealthInfoId: "healthinfo001"
            )
        ]
    }
}
