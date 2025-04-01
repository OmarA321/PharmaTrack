//
//  User.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import Foundation

enum UserType: String, Codable {
    case patient
    case pharmacist
}

struct User: Identifiable, Codable {
    var id: String? = nil
    var username: String
    var email: String
    var firstName: String
    var lastName: String
    var dateOfBirth: Date
    var phoneNumber: String
    var healthConditions: [String]
    var allergies: [String]
    var familyMembers: [FamilyMember]
    var profileImageName: String? = "default_profile"
    var userType: UserType = .patient
    
    // Pharmacist specific fields
    var pharmacyName: String?
    var licenseNumber: String?
    
    // For gamification
    var adherenceScore: Int = 0
    var badges: [Badge] = []
    var healthInfoRead: [String] = []
    var minigamesPlayed: Int = 0
    
    static var example: User {
        User(
            id: UUID().uuidString,
            username: "johndoe",
            email: "john@example.com",
            firstName: "John",
            lastName: "Doe",
            dateOfBirth: Date(timeIntervalSince1970: 320025600), // Example date
            phoneNumber: "555-123-4567",
            healthConditions: ["Hypertension", "Type 2 Diabetes"],
            allergies: ["Penicillin", "Pollen"],
            familyMembers: [
                FamilyMember.example
            ]
        )
    }
}

struct FamilyMember: Identifiable, Codable {
    var id: String = UUID().uuidString
    var relationship: String // e.g., "Child", "Parent", "Spouse"
    var firstName: String
    var lastName: String
    var dateOfBirth: Date
    var healthConditions: [String]
    var allergies: [String]
    
    static var example: FamilyMember {
        FamilyMember(
            relationship: "Child",
            firstName: "Emma",
            lastName: "Doe",
            dateOfBirth: Date(timeIntervalSince1970: 978307200), // Example date
            healthConditions: ["Asthma"],
            allergies: ["Nuts"]
        )
    }
}
