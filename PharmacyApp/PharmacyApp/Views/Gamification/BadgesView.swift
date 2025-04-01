//
//  BadgesView.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import SwiftUI

struct BadgesView: View {
    @EnvironmentObject private var gamificationViewModel: GamificationViewModel
    @State private var selectedCategory: Badge.BadgeCategory?
    @State private var searchText: String = ""
    
    var filteredBadges: [Badge] {
        var badges = gamificationViewModel.badges
        
        // Filter by category if selected
        if let category = selectedCategory {
            badges = badges.filter { $0.category == category }
        }
        
        // Filter by search text if not empty
        if !searchText.isEmpty {
            badges = badges.filter {
                $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.description.lowercased().contains(searchText.lowercased())
            }
        }
        
        return badges
    }
    
    var categoryCounts: [Badge.BadgeCategory: Int] {
        var counts: [Badge.BadgeCategory: Int] = [:]
        
        for badge in gamificationViewModel.badges {
            counts[badge.category, default: 0] += 1
        }
        
        return counts
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Search and filter bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search badges", text: $searchText)
                        .foregroundColor(Color("TextColor"))
                }
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            .padding(.horizontal)
            
            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // All badges button
                    Button(action: {
                        selectedCategory = nil
                    }) {
                        VStack(spacing: 4) {
                            Text("All")
                                .font(.subheadline)
                                .foregroundColor(selectedCategory == nil ? Color("PrimaryBlue") : .gray)
                            
                            Text("\(gamificationViewModel.badges.count)")
                                .font(.caption)
                                .foregroundColor(selectedCategory == nil ? Color("PrimaryBlue") : .gray)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(selectedCategory == nil ? Color("PrimaryBlue").opacity(0.1) : Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedCategory == nil ? Color("PrimaryBlue") : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // Category buttons
                    ForEach(Badge.BadgeCategory.allCases, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            VStack(spacing: 4) {
                                Text(categoryDisplayName(category))
                                    .font(.subheadline)
                                    .foregroundColor(selectedCategory == category ? categoryColor(category) : .gray)
                                
                                Text("\(categoryCounts[category, default: 0])")
                                    .font(.caption)
                                    .foregroundColor(selectedCategory == category ? categoryColor(category) : .gray)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(selectedCategory == category ? categoryColor(category).opacity(0.1) : Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedCategory == category ? categoryColor(category) : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            if filteredBadges.isEmpty {
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "medal.fill")
                        .font(.system(size: 70))
                        .foregroundColor(Color("PrimaryBlue").opacity(0.5))
                    
                    Text("No badges found")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    if !searchText.isEmpty {
                        Text("Try a different search term")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else if selectedCategory != nil {
                        Text("Try a different category filter")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
            } else {
                // Badges grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                        ForEach(filteredBadges) { badge in
                            BadgeCardView(badge: badge)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
        .background(Color("BackgroundColor"))
        .navigationTitle("Your Badges")
    }
    
    // Helper functions
    private func categoryDisplayName(_ category: Badge.BadgeCategory) -> String {
        switch category {
        case .adherence:
            return "Adherence"
        case .vaccine:
            return "Vaccines"
        case .medsCheck:
            return "Med Reviews"
        case .healthInfo:
            return "Health Info"
        case .activity:
            return "Activity"
        }
    }
    
    private func categoryColor(_ category: Badge.BadgeCategory) -> Color {
        switch category {
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

struct BadgeCardView: View {
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

// Extension to make Badge.BadgeCategory conform to CaseIterable
extension Badge.BadgeCategory: CaseIterable {
    public static var allCases: [Badge.BadgeCategory] {
        [.adherence, .vaccine, .medsCheck, .healthInfo, .activity]
    }
}

struct BadgesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BadgesView()
                .environmentObject(GamificationViewModel())
        }
    }
}
