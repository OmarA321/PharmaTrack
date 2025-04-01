//
//  HealthInfoView.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import SwiftUI

struct HealthInfoView: View {
    @EnvironmentObject private var gamificationViewModel: GamificationViewModel
    @State private var selectedCategory: HealthInfo.HealthInfoCategory?
    @State private var searchText: String = ""
    @State private var selectedInfo: HealthInfo?
    @State private var showDetailView = false
    
    var filteredHealthInfo: [HealthInfo] {
        var infos = gamificationViewModel.healthInfos
        
        // Filter by category if selected
        if let category = selectedCategory {
            infos = infos.filter { $0.category == category }
        }
        
        // Filter by search text if not empty
        if !searchText.isEmpty {
            infos = infos.filter {
                $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.summary.lowercased().contains(searchText.lowercased()) ||
                $0.content.lowercased().contains(searchText.lowercased())
            }
        }
        
        return infos
    }
    
    var categoryCounts: [HealthInfo.HealthInfoCategory: Int] {
        var counts: [HealthInfo.HealthInfoCategory: Int] = [:]
        
        for info in gamificationViewModel.healthInfos {
            counts[info.category, default: 0] += 1
        }
        
        return counts
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Search bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search health information", text: $searchText)
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
                    // All info button
                    Button(action: {
                        selectedCategory = nil
                    }) {
                        VStack(spacing: 4) {
                            Text("All")
                                .font(.subheadline)
                                .foregroundColor(selectedCategory == nil ? Color("PrimaryBlue") : .gray)
                            
                            Text("\(gamificationViewModel.healthInfos.count)")
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
                    ForEach(HealthInfo.HealthInfoCategory.allCases, id: \.self) { category in
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
            
            // Content
            if filteredHealthInfo.isEmpty {
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 70))
                        .foregroundColor(Color("PrimaryBlue").opacity(0.5))
                    
                    Text("No health information found")
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
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredHealthInfo) { info in
                            HealthInfoCardView(healthInfo: info)
                                .onTapGesture {
                                    selectedInfo = info
                                    showDetailView = true
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
        .background(Color("BackgroundColor"))
        .navigationTitle("Health Information")
        .sheet(isPresented: $showDetailView) {
            if let info = selectedInfo {
                HealthInfoDetailView(healthInfo: info, isPresented: $showDetailView)
                    .environmentObject(gamificationViewModel)
            }
        }
    }
    
    // Helper functions
    private func categoryDisplayName(_ category: HealthInfo.HealthInfoCategory) -> String {
        switch category {
        case .general:
            return "General"
        case .condition:
            return "Conditions"
        case .medication:
            return "Medications"
        case .awareness:
            return "Awareness"
        case .nutrition:
            return "Nutrition"
        case .exercise:
            return "Exercise"
        }
    }
    
    private func categoryColor(_ category: HealthInfo.HealthInfoCategory) -> Color {
        switch category {
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

struct HealthInfoCardView: View {
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

struct HealthInfoDetailView: View {
    let healthInfo: HealthInfo
    @Binding var isPresented: Bool
    @EnvironmentObject private var gamificationViewModel: GamificationViewModel
    @State private var showingBadgeAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Category indicator
                    Text(healthInfo.category.rawValue)
                        .font(.subheadline)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 12)
                        .background(categoryColor.opacity(0.2))
                        .foregroundColor(categoryColor)
                        .cornerRadius(8)
                    
                    // Title
                    Text(healthInfo.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TextColor"))
                    
                    // Summary
                    Text(healthInfo.summary)
                        .font(.headline)
                        .foregroundColor(Color("TextColor"))
                        .padding(.bottom, 8)
                    
                    // Content
                    Text(healthInfo.content)
                        .font(.body)
                        .foregroundColor(Color("TextColor"))
                        .lineSpacing(4)
                    
                    // Related info
                    if healthInfo.awardsBadge {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Earn a Badge")
                                .font(.headline)
                                .foregroundColor(Color("TextColor"))
                            
                            HStack {
                                Image(systemName: "medal.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.yellow)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Health Knowledge Badge")
                                        .font(.subheadline)
                                        .foregroundColor(Color("TextColor"))
                                    
                                    Text("Awarded for reading health information articles")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // Share button
                    Button(action: {
                        // Share action (would be implemented in a real app)
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share this information")
                        }
                        .font(.headline)
                        .foregroundColor(Color("PrimaryBlue"))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("PrimaryBlue").opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.top, 16)
                }
                .padding()
            }
            .navigationBarTitle("Health Information", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                isPresented = false
            }) {
                Text("Done")
                    .foregroundColor(Color("PrimaryBlue"))
            })
            .onDisappear {
                // Mark as read and check for badge
                if !healthInfo.isRead {
                    gamificationViewModel.markHealthInfoAsRead(healthInfo.id)
                    
                    if healthInfo.awardsBadge {
                        showingBadgeAlert = true
                    }
                }
            }
            .alert(isPresented: $showingBadgeAlert) {
                Alert(
                    title: Text("Badge Earned!"),
                    message: Text("You've earned a Health Knowledge badge for reading this article."),
                    dismissButton: .default(Text("Great!"))
                )
            }
        }
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

// Extension to make HealthInfo.HealthInfoCategory conform to CaseIterable
extension HealthInfo.HealthInfoCategory: CaseIterable {
    public static var allCases: [HealthInfo.HealthInfoCategory] {
        [.general, .condition, .medication, .awareness, .nutrition, .exercise]
    }
}

struct HealthInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HealthInfoView()
                .environmentObject(GamificationViewModel())
        }
    }
}
