//
//  Prescription.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import Foundation

enum PrescriptionStatus: String, Codable {
    case requestReceived = "Request Received"
    case entered = "Entered into System"
    case pharmacistCheck = "Pharmacist Check"
    case prepPackaging = "Prep & Packaging"
    case billing = "Billing"
    case readyForPickup = "Ready for Pickup"
    case completed = "Completed"
}

enum PrescriptionType: String, Codable {
    case new = "New Prescription"
    case refill = "Refill"
}

struct ChatMessage: Identifiable, Codable {
    var id: String
    var content: String
    var timestamp: Date
    var isFromUser: Bool // true if from user, false if from pharmacist
}

struct Prescription: Identifiable, Codable {
    var id: String = UUID().uuidString
    var rxNumber: String
    var medicationName: String
    var dosage: String
    var instructions: String
    var prescribedDate: Date
    var expiryDate: Date
    var refillsRemaining: Int
    var status: PrescriptionStatus
    var type: PrescriptionType
    var forUser: String  // User ID or family member ID
    var forUserName: String // User or family member name
    var statusHistory: [StatusUpdate] = []
    var notes: String?  
    var pharmacistMessage: String? // Legacy field - kept for backward compatibility
    var pharmacistMessages: [ChatMessage]? // New field for two-way messaging
    var imageUrl: String?

    
    // Cost info
    var totalCost: Double?
    var insuranceCoverage: Double?
    var copayAmount: Double?
    var dispensingFee: Double?
    
    // For notifications
    var notifiedOnStatusChange: Bool = false
    
    // For adherence tracking (gamification)
    var adherencePercentage: Double = 100.0
    var lastTaken: Date?
    var nextDueDate: Date?
    
    static var example: Prescription {
        let now = Date()
        var prescription = Prescription(
            rxNumber: "RX123456",
            medicationName: "Metformin",
            dosage: "500mg",
            instructions: "Take one tablet twice daily with meals",
            prescribedDate: now.addingTimeInterval(-86400 * 7), // 7 days ago
            expiryDate: now.addingTimeInterval(86400 * 180), // 180 days in future
            refillsRemaining: 3,
            status: .prepPackaging,
            type: .refill,
            forUser: "user123",
            forUserName: "John Doe",
            totalCost: 45.99,
            insuranceCoverage: 35.00,
            copayAmount: 10.99,
            dispensingFee: 12.99
        )
        
        // Add status history
        prescription.statusHistory = [
            StatusUpdate(status: .requestReceived, timestamp: now.addingTimeInterval(-86400 * 2), message: "Your prescription refill request has been received"),
            StatusUpdate(status: .entered, timestamp: now.addingTimeInterval(-86400 * 1.5)),
            StatusUpdate(status: .pharmacistCheck, timestamp: now.addingTimeInterval(-86400 * 1)),
            StatusUpdate(status: .prepPackaging, timestamp: now)
        ]
        
        // No pharmacist messages by default - most prescriptions don't need them
        return prescription
    }
    
    // Create an example with pharmacist message for demo
    static var exampleWithPharmacistMessage: Prescription {
        let now = Date()
        var prescription = Prescription(
            rxNumber: "RX123890",
            medicationName: "Amoxicillin",
            dosage: "500mg",
            instructions: "Take one capsule three times daily with food",
            prescribedDate: now.addingTimeInterval(-86400 * 3), // 3 days ago
            expiryDate: now.addingTimeInterval(86400 * 14), // 14 days in future
            refillsRemaining: 0,
            status: .pharmacistCheck,
            type: .new,
            forUser: "user123",
            forUserName: "John Doe",
            totalCost: 25.99,
            insuranceCoverage: 15.00,
            copayAmount: 10.99,
            dispensingFee: 12.99
        )
        
        // Add status history
        prescription.statusHistory = [
            StatusUpdate(status: .requestReceived, timestamp: now.addingTimeInterval(-86400 * 1.5)),
            StatusUpdate(status: .entered, timestamp: now.addingTimeInterval(-86400 * 1)),
            StatusUpdate(status: .pharmacistCheck, timestamp: now.addingTimeInterval(-3600 * 5),
                         message: "Pharmacist identified a potential drug interaction")
        ]
        
        // Example of pharmacist messages for this prescription that has an issue
        prescription.pharmacistMessage = "We've identified a potential interaction with your current medications. Have you taken this medication before?"
        prescription.pharmacistMessages = [
            ChatMessage(
                id: UUID().uuidString,
                content: "Hello, we noticed this medication might interact with your current prescription for Lisinopril. Have you taken Amoxicillin before?",
                timestamp: now.addingTimeInterval(-3600), // 1 hour ago
                isFromUser: false
            )
        ]
        
        return prescription
    }
    
    // Function to add a pharmacist message (only to be used by pharmacist interface)
    mutating func addPharmacistMessage(_ content: String) {
        let message = ChatMessage(
            id: UUID().uuidString,
            content: content,
            timestamp: Date(),
            isFromUser: false
        )
        
        if pharmacistMessages == nil {
            pharmacistMessages = [message]
        } else {
            pharmacistMessages?.append(message)
        }
    }
    
    // Function to add a user message (only allowed after pharmacist has initiated conversation)
    mutating func addUserReply(_ content: String) -> Bool {
        // Check if pharmacist has initiated conversation
        if let messages = pharmacistMessages, !messages.filter({ !$0.isFromUser }).isEmpty {
            let message = ChatMessage(
                id: UUID().uuidString,
                content: content,
                timestamp: Date(),
                isFromUser: true
            )
            
            pharmacistMessages?.append(message)
            return true
        }
        return false // Cannot add user message if pharmacist hasn't initiated
    }
}

struct StatusUpdate: Codable {
    var status: PrescriptionStatus
    var timestamp: Date
    var message: String?
}
