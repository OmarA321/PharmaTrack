//
//  NotificationViewModel.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import Foundation
import Combine

class NotificationViewModel: ObservableObject {
    @Published var notifications: [AppNotification] = []
    @Published var unreadCount: Int = 0
    
    init() {
        // Load mock data for prototype
        loadMockData()
        calculateUnreadCount()
    }
    
    private func loadMockData() {
        // In a real app, this would fetch from a server
        self.notifications = AppNotification.examples
    }
    
    private func calculateUnreadCount() {
        unreadCount = notifications.filter { !$0.isRead }.count
    }
    
    func markAsRead(_ notificationId: String) {
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            notifications[index].isRead = true
            calculateUnreadCount()
        }
    }
    
    func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
        calculateUnreadCount()
    }
    
    func addNotification(for prescription: Prescription) {
        // Create notification based on prescription status
        var notification: AppNotification?
        
        switch prescription.status {
        case .requestReceived:
            notification = AppNotification(
                type: .requestReceived,
                title: "Prescription Request Received",
                message: "Your \(prescription.type.rawValue.lowercased()) for \(prescription.medicationName) has been received",
                timestamp: Date(),
                prescriptionId: prescription.id
            )
        case .prepPackaging:
            notification = AppNotification(
                type: .prepPackaging,
                title: "Prescription Being Prepared",
                message: "Your prescription for \(prescription.medicationName) is being prepared",
                timestamp: Date(),
                prescriptionId: prescription.id
            )
        case .readyForPickup:
            notification = AppNotification(
                type: .readyForPickup,
                title: "Ready for Pickup",
                message: "Your prescription for \(prescription.medicationName) is ready for pickup",
                timestamp: Date(),
                prescriptionId: prescription.id
            )
        default:
            break
        }
        
        // Add pharmacist message notification if there is one
        if let message = prescription.pharmacistMessage {
            notification = AppNotification(
                type: .pharmacistMessage,
                title: "Message from Pharmacist",
                message: message,
                timestamp: Date(),
                prescriptionId: prescription.id
            )
        }
        
        if let notification = notification {
            notifications.insert(notification, at: 0)
            calculateUnreadCount()
        }
    }
    
    func addHealthInfoNotification(healthInfo: HealthInfo) {
        let notification = AppNotification(
            type: .healthInfo,
            title: "New Health Information",
            message: "New article: \(healthInfo.title)",
            timestamp: Date(),
            relatedHealthInfoId: healthInfo.id
        )
        
        notifications.insert(notification, at: 0)
        calculateUnreadCount()
    }
    
    func addBadgeNotification(badge: Badge) {
        let notification = AppNotification(
            type: .badge,
            title: "New Badge Earned!",
            message: "Congratulations! You've earned the '\(badge.title)' badge.",
            timestamp: Date(),
            relatedBadgeId: badge.id
        )
        
        notifications.insert(notification, at: 0)
        calculateUnreadCount()
    }
    
    func addAdherenceReminder(prescription: Prescription) {
        let notification = AppNotification(
            type: .adherenceReminder,
            title: "Medication Reminder",
            message: "Time to take your \(prescription.medicationName) (\(prescription.dosage))",
            timestamp: Date(),
            prescriptionId: prescription.id
        )
        
        notifications.insert(notification, at: 0)
        calculateUnreadCount()
    }
}
