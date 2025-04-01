//
//  PharmacyAppApp.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//


import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct PharmacyAppApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var prescriptionViewModel = PrescriptionViewModel()
    @StateObject private var notificationViewModel = NotificationViewModel()
    @StateObject private var gamificationViewModel = GamificationViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userViewModel)
                .environmentObject(prescriptionViewModel)
                .environmentObject(notificationViewModel)
                .environmentObject(gamificationViewModel)
                .preferredColorScheme(.light)
        }
    }
}
