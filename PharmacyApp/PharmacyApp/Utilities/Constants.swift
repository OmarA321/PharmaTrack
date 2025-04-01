//
//  Constants.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import SwiftUI

struct AppColors {
    static let primaryBlue = Color("PrimaryBlue")
    static let secondaryBlue = Color("SecondaryBlue")
    static let backgroundColor = Color("BackgroundColor")
    static let textColor = Color("TextColor")
    
    // Status colors
    static let statusReceived = Color.blue
    static let statusEntered = Color.orange
    static let statusCheck = Color.orange
    static let statusPrep = Color.purple
    static let statusBilling = Color.gray
    static let statusReady = Color.green
    static let statusCompleted = Color.gray
    
    // Health indicator colors
    static let healthExcellent = Color.green
    static let healthGood = Color.orange
    static let healthPoor = Color.red
}

struct AppFonts {
    static let title = Font.title.weight(.bold)
    static let title2 = Font.title2.weight(.bold)
    static let title3 = Font.title3.weight(.bold)
    static let headline = Font.headline
    static let subheadline = Font.subheadline
    static let body = Font.body
    static let caption = Font.caption
}

struct AppImages {
    static let placeholder = "placeholder"
    static let logo = "logo"
    
    // Tab icons
    static let tabPrescriptions = "pill"
    static let tabNotifications = "bell"
    static let tabJourney = "trophy"
    static let tabProfile = "person"
    
    // Game icons
    static let gameMatch = "game_match"
    static let gamePursuit = "game_pursuit"
    static let gameQuiz = "game_quiz"
    static let gameExplorer = "game_explorer"
    
    // Badge icons
    static let badgeAdherenceStar = "badge_adherence_star"
    static let badgeVaccineFlu = "badge_vaccine_flu"
    static let badgeHealthInfo = "badge_health_info"
    static let badgeMedsCheck = "badge_meds_check"
    static let badgeFamilyCare = "badge_family_care"
}

struct AppStrings {
    static let appName = "PharmacyPal"
    static let tagline = "Your health journey companion"
    
    // Common button texts
    static let save = "Save"
    static let cancel = "Cancel"
    static let delete = "Delete"
    static let edit = "Edit"
    static let add = "Add"
    static let done = "Done"
    
    // Notification texts
    static let successTitle = "Success"
    static let errorTitle = "Error"
    static let warningTitle = "Warning"
    static let infoTitle = "Information"
}

struct AppMetrics {
    static let standardPadding: CGFloat = 16
    static let smallPadding: CGFloat = 8
    static let largePadding: CGFloat = 24
    
    static let cornerRadius: CGFloat = 12
    static let smallCornerRadius: CGFloat = 8
    static let largeCornerRadius: CGFloat = 16
    
    static let iconSize: CGFloat = 24
    static let smallIconSize: CGFloat = 16
    static let largeIconSize: CGFloat = 32
    
    static let profileImageSize: CGFloat = 100
    static let avatarSize: CGFloat = 44
}

struct AppAnimations {
    static let standard = Animation.easeInOut(duration: 0.3)
    static let quick = Animation.easeInOut(duration: 0.15)
    static let long = Animation.easeInOut(duration: 0.5)
}
