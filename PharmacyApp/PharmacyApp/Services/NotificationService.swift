//
//  NotificationService.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//
import Foundation
import SwiftUI

class NotificationService {
    // Singleton instance
    static let shared = NotificationService()
    private init() {}
    
    // Track scheduled local notifications
    private var scheduledNotifications: [String: Date] = [:]
    
    // MARK: - Notification Management
    
    /// Schedule a local notification for a prescription status change
    func scheduleNotification(for prescription: Prescription) {
        // Only schedule notifications for three specific statuses
        switch prescription.status {
        case .requestReceived, .prepPackaging, .readyForPickup:
            // In a real app, this would use UNUserNotificationCenter to schedule actual notifications
            print("📱 Would schedule notification for \(prescription.medicationName) - Status: \(prescription.status.rawValue)")
            scheduledNotifications[prescription.id] = Date()
        default:
            break
        }
    }
    
    /// Schedule a medication reminder notification
    func scheduleAdherenceReminder(for prescription: Prescription, at date: Date) {
        // In a real app, this would use UNUserNotificationCenter to schedule actual reminders
        print("⏰ Would schedule adherence reminder for \(prescription.medicationName) at \(formatDate(date))")
        scheduledNotifications["\(prescription.id)_reminder"] = date
    }
    
    /// Schedule notification for new health information
    func scheduleHealthInfoNotification(for healthInfo: HealthInfo) {
        // In a real app, this would use UNUserNotificationCenter to schedule actual notifications
        print("💊 Would schedule health info notification: \(healthInfo.title)")
        scheduledNotifications[healthInfo.id] = Date()
    }
    
    /// Schedule badge earned notification
    func scheduleBadgeNotification(for badge: Badge) {
        // In a real app, this would use UNUserNotificationCenter to schedule actual notifications
        print("🏅 Would schedule badge notification: \(badge.title)")
        scheduledNotifications[badge.id] = Date()
    }
    
    /// Cancel a specific notification
    func cancelNotification(id: String) {
        // In a real app, this would use UNUserNotificationCenter to cancel a notification
        print("❌ Would cancel notification with ID: \(id)")
        scheduledNotifications.removeValue(forKey: id)
    }
    
    /// Cancel all notifications
    func cancelAllNotifications() {
        // In a real app, this would use UNUserNotificationCenter to cancel all notifications
        print("❌ Would cancel all notifications")
        scheduledNotifications.removeAll()
    }
    
    // MARK: - Notification History Tracking
    
    /// Get all scheduled notification info (for the prototype)
    func getScheduledNotifications() -> [String: Date] {
        return scheduledNotifications
    }
    
    /// Check if a notification is scheduled for a prescription
    func isNotificationScheduled(for prescriptionId: String) -> Bool {
        return scheduledNotifications[prescriptionId] != nil
    }
    
    // MARK: - Helper Methods
    
    /// Format date for display
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // MARK: - Mock Notification Generation (for prototype)
    
    /// Create a mock notification for the UI
    func createMockNotification(for prescription: Prescription) -> AppNotification {
        var type: NotificationType
        var title: String
        var message: String
        
        switch prescription.status {
        case .requestReceived:
            type = .requestReceived
            title = "Prescription Request Received"
            message = "Your \(prescription.type.rawValue.lowercased()) for \(prescription.medicationName) has been received"
            
        case .prepPackaging:
            type = .prepPackaging
            title = "Prescription Being Prepared"
            message = "Your prescription for \(prescription.medicationName) is being prepared"
            
        case .readyForPickup:
            type = .readyForPickup
            title = "Ready for Pickup"
            message = "Your prescription for \(prescription.medicationName) is ready for pickup"
            
        default:
            // For other statuses, create a generic update
            type = .info
            title = "Prescription Update"
            message = "Your prescription for \(prescription.medicationName) has been updated to: \(prescription.status.rawValue)"
        }
        
        // Create pharmacist message notification if there is one
        if let pharmacistMessage = prescription.pharmacistMessage {
            type = .pharmacistMessage
            title = "Message from Pharmacist"
            message = pharmacistMessage
        }
        
        return AppNotification(
            type: type,
            title: title,
            message: message,
            timestamp: Date(),
            prescriptionId: prescription.id
        )
    }
    
    /// Create a mock adherence reminder notification
    func createMockAdherenceReminder(for prescription: Prescription) -> AppNotification {
        return AppNotification(
            type: .adherenceReminder,
            title: "Medication Reminder",
            message: "Time to take your \(prescription.medicationName) (\(prescription.dosage))",
            timestamp: Date(),
            prescriptionId: prescription.id
        )
    }
    
    /// Create a mock badge notification
    func createMockBadgeNotification(for badge: Badge) -> AppNotification {
        return AppNotification(
            type: .badge,
            title: "New Badge Earned!",
            message: "Congratulations! You've earned the '\(badge.title)' badge.",
            timestamp: Date(),
            relatedBadgeId: badge.id
        )
    }
    
    /// Create a mock health info notification
    func createMockHealthInfoNotification(for healthInfo: HealthInfo) -> AppNotification {
        return AppNotification(
            type: .healthInfo,
            title: "New Health Information",
            message: "New article: \(healthInfo.title)",
            timestamp: Date(),
            relatedHealthInfoId: healthInfo.id
        )
    }
}
