//
//  ContentView.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if userViewModel.isLoggedIn {
                TabView(selection: $selectedTab) {
                    // Home/Dashboard
                    NavigationView {
                        PrescriptionListView()
                            .navigationTitle("My Prescriptions")
                    }
                    .tabItem {
                        Label("Prescriptions", systemImage: "pill")
                    }
                    .tag(0)
                    
                    // Notifications
                    NavigationView {
                        NotificationListView()
                            .navigationTitle("Notifications")
                    }
                    .tabItem {
                        Label("Notifications", systemImage: "bell")
                    }
                    .tag(1)
                    
                    // Gamification
                    NavigationView {
                        GamificationDashboardView()
                            .navigationTitle("Health Journey")
                    }
                    .tabItem {
                        Label("My Journey", systemImage: "trophy")
                    }
                    .tag(2)
                    
                    // Profile
                    NavigationView {
                        ProfileView()
                            .navigationTitle("My Profile")
                    }
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                    .tag(3)
                }
                .accentColor(.blue) // Changed from Color("PrimaryBlue") to system .blue
                .onAppear {
                    // Set the tab bar appearance
                    UITabBar.appearance().backgroundColor = UIColor.systemBackground
                }
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserViewModel())
            .environmentObject(PrescriptionViewModel())
            .environmentObject(NotificationViewModel())
            .environmentObject(GamificationViewModel())
    }
}
