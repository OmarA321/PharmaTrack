//
//  GamificationDashboardView.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import SwiftUI

struct GamificationDashboardView: View {
    @EnvironmentObject private var gamificationViewModel: GamificationViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Level and points header
                VStack(spacing: 8) {
                    let userLevel = gamificationViewModel.getUserLevel()
                    
                    Text("Level \(userLevel.level)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color("PrimaryBlue"))
                    
                    Text("Health Champion")
                        .font(.headline)
                        .foregroundColor(Color("TextColor"))
                    
                    // Level progress bar
                    VStack(alignment: .leading, spacing: 4) {
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 5)
                                .frame(height: 10)
                                .foregroundColor(Color.gray.opacity(0.2))
                            
                            RoundedRectangle(cornerRadius: 5)
                                .frame(width: CGFloat(userLevel.progress) * UIScreen.main.bounds.width * 0.9, height: 10)
                                .foregroundColor(Color("PrimaryBlue"))
                        }
                        
                        HStack {
                            Text("\(gamificationViewModel.totalPoints) points")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text("\(Int(userLevel.progress * 100))% to Level \(userLevel.level + 1)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding()
                
                // Category tabs
                HStack {
                    ForEach(["Badges", "Adherence", "Health Info", "Minigames"], id: \.self) { category in
                        Button(action: {
                            withAnimation {
                                selectedTab = ["Badges", "Adherence", "Health Info", "Minigames"].firstIndex(of: category) ?? 0
                            }
                        }) {
                            VStack(spacing: 4) {
                                Text(category)
                                    .font(.subheadline)
                                    .foregroundColor(selectedTab == ["Badges", "Adherence", "Health Info", "Minigames"].firstIndex(of: category) ? Color("PrimaryBlue") : .gray)
                                
                                // Indicator line
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(selectedTab == ["Badges", "Adherence", "Health Info", "Minigames"].firstIndex(of: category) ? Color("PrimaryBlue") : .clear)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal)
                .background(Color.white)
                
                // Tab content
                TabView(selection: $selectedTab) {
                    // Badges Tab
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                            ForEach(gamificationViewModel.badges) { badge in
                                BadgeCard(badge: badge)
                            }
                        }
                        .padding()
                    }
                    .tag(0)
                    
                    // Adherence Tab
                    ScrollView {
                        VStack(spacing: 16) {
                            // Adherence score
                            VStack(spacing: 12) {
                                Text("Medication Adherence")
                                    .font(.headline)
                                    .foregroundColor(Color("TextColor"))
                                
                                // Circular progress indicator
                                ZStack {
                                    Circle()
                                        .stroke(lineWidth: 15)
                                        .opacity(0.3)
                                        .foregroundColor(Color("PrimaryBlue"))
                                    
                                    Circle()
                                        .trim(from: 0.0, to: CGFloat(gamificationViewModel.adherenceScore) / 100)
                                        .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                                        .foregroundColor(Color("PrimaryBlue"))
                                        .rotationEffect(Angle(degrees: 270.0))
                                    
                                    VStack(spacing: 4) {
                                        Text("\(gamificationViewModel.adherenceScore)%")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(Color("PrimaryBlue"))
                                        
                                        Text(gamificationViewModel.getAdherenceLevel())
                                            .font(.headline)
                                            .foregroundColor(Color("TextColor"))
                                    }
                                }
                                .frame(width: 200, height: 200)
                                .padding(.vertical, 16)
                                
                                // Adherence tips
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Tips to Improve Adherence")
                                        .font(.headline)
                                        .foregroundColor(Color("TextColor"))
                                    
                                    ForEach(adherenceTips, id: \.self) { tip in
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(Color("PrimaryBlue"))
                                                .padding(.top, 2)
                                            
                                            Text(tip)
                                                .font(.body)
                                                .foregroundColor(Color("TextColor"))
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }
                        }
                        .padding()
                    }
                    .tag(1)
                    
                    // Health Info Tab
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(gamificationViewModel.healthInfos) { healthInfo in
                                HealthInfoCard(healthInfo: healthInfo)
                                    .onTapGesture {
                                        // In a real app, this would navigate to the health info detail
                                        gamificationViewModel.markHealthInfoAsRead(healthInfo.id)
                                    }
                            }
                        }
                        .padding()
                    }
                    .tag(2)
                    
                    // Minigames Tab
                    ScrollView {
                        VStack(spacing: 20) {
                            // Stats
                            HStack {
                                Spacer()
                                
                                VStack {
                                    Text("\(gamificationViewModel.minigamesPlayed)")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(Color("PrimaryBlue"))
                                    
                                    Text("Games Played")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                VStack {
                                    Text("\(gamificationViewModel.minigamesWon)")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(Color("PrimaryBlue"))
                                    
                                    Text("Games Won")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                VStack {
                                    let winRate = gamificationViewModel.minigamesPlayed > 0 ?
                                        Double(gamificationViewModel.minigamesWon) / Double(gamificationViewModel.minigamesPlayed) * 100 : 0
                                    
                                    Text("\(Int(winRate))%")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(Color("PrimaryBlue"))
                                    
                                    Text("Win Rate")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            
                            // Available games placeholder
                            // (In a real app, you would connect this to actual minigames)
                            Text("Minigames coming soon!")
                                .font(.headline)
                                .foregroundColor(Color("TextColor"))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .padding()
                    }
                    .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
    }
    
    // Sample adherence tips
    private let adherenceTips = [
        "Set alarms on your phone for medication times",
        "Use a pill organizer to track your doses",
        "Link medication taking to daily routines like brushing teeth",
        "Keep a medication journal or use this app to track adherence",
        "Ask family members to help remind you"
    ]
}

struct BadgeCard: View {
    let badge: Badge
    
    var body: some View {
        VStack {
            // Badge icon (in a real app, this would be an image)
            ZStack {
                Circle()
                    .fill(badgeColor.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: badgeIcon)
                    .font(.system(size: 40))
                    .foregroundColor(badgeColor)
            }
            .padding(.top, 16)
            
            Text(badge.title)
                .font(.headline)
                .foregroundColor(Color("TextColor"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
            
            Text(badge.description)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
                .padding(.bottom, 4)
            
            Text("\(badge.points) pts")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.vertical, 4)
                .padding(.horizontal, 12)
                .background(badgeColor)
                .cornerRadius(12)
                .padding(.bottom, 16)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // Map badge categories to icons and colors
    private var badgeIcon: String {
        switch badge.category {
        case .adherence:
            return "pills.fill"
        case .vaccine:
            return "syringe.fill"
        case .medsCheck:
            return "checklist.fill"
        case .healthInfo:
            return "heart.text.square.fill"
        case .activity:
            return "figure.walk"
        }
    }
    
    private var badgeColor: Color {
        switch badge.category {
        case .adherence:
            return .purple
        case .vaccine:
            return .blue
        case .medsCheck:
            return .green
        case .healthInfo:
            return .pink
        case .activity:
            return .orange
        }
    }
}

struct HealthInfoCard: View {
    let healthInfo: HealthInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Category indicator
                Text(healthInfo.category.rawValue)
                    .font(.caption)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(categoryColor.opacity(0.2))
                    .foregroundColor(categoryColor)
                    .cornerRadius(4)
                
                Spacer()
                
                // Read indicator
                if healthInfo.isRead {
                    Text("Read")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Text(healthInfo.title)
                .font(.headline)
                .foregroundColor(Color("TextColor"))
            
            Text(healthInfo.summary)
                .font(.body)
                .foregroundColor(Color("TextColor"))
                .lineLimit(2)
            
            HStack {
                if healthInfo.awardsBadge {
                    Image(systemName: "medal.fill")
                        .foregroundColor(.yellow)
                    
                    Text("Earn a badge by reading")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("Read Article")
                    .font(.subheadline)
                    .foregroundColor(Color("PrimaryBlue"))
            }
        }
        .padding()
        .background(Color.white)
        .opacity(healthInfo.isRead ? 0.8 : 1.0)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // Map health info categories to colors
    private var categoryColor: Color {
        switch healthInfo.category {
        case .general:
            return .blue
        case .condition:
            return .purple
        case .medication:
            return .green
        case .awareness:
            return .orange
        case .nutrition:
            return .pink
        case .exercise:
            return .red
        }
    }
}

struct GamificationDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GamificationDashboardView()
                .environmentObject(GamificationViewModel())
                .environmentObject(UserViewModel())
        }
    }
}
