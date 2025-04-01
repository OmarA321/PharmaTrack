//
//  ProfileView.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var showingFamilyMemberSheet = false
    @State private var showingHealthDataSheet = false
    @State private var showingSettingsSheet = false
    @State private var selectedFamilyMember: FamilyMember?
    
    // Date formatter for readable dates
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var userInitials: String {
        let firstName = userViewModel.currentUser?.firstName ?? ""
        let lastName = userViewModel.currentUser?.lastName ?? ""
        
        let firstInitial = firstName.first?.uppercased() ?? ""
        let lastInitial = lastName.first?.uppercased() ?? ""
        
        return "\(firstInitial)\(lastInitial)"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // User profile header
                VStack(spacing: 16) {
                    // Profile image
                    ZStack {
                        Circle()
                            .fill(Color("PrimaryBlue").opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        Text(userInitials)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color("PrimaryBlue"))
                    }
                    
                    Text("\(userViewModel.currentUser?.firstName ?? "") \(userViewModel.currentUser?.lastName ?? "")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TextColor"))
                    
                    HStack(spacing: 40) {
                        VStack {
                            Text("\(userViewModel.currentUser?.familyMembers.count ?? 0)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(Color("PrimaryBlue"))
                            
                            Text("Family\nMembers")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        
                        VStack {
                            let count = userViewModel.currentUser?.badges.count ?? 0
                            Text("\(count)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(Color("PrimaryBlue"))
                            
                            Text("Badges\nEarned")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        
                        VStack {
                            let score = userViewModel.currentUser?.adherenceScore ?? 0
                            Text("\(score)%")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(Color("PrimaryBlue"))
                            
                            Text("Adherence\nScore")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Personal information
                VStack(alignment: .leading, spacing: 16) {
                    Text("Personal Information")
                        .font(.headline)
                        .foregroundColor(Color("TextColor"))
                    
                    HStack {
                        Text("Email")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: 100, alignment: .leading)
                        
                        Text(userViewModel.currentUser?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(Color("TextColor"))
                    }
                    
                    HStack {
                        Text("Phone")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: 100, alignment: .leading)
                        
                        Text(userViewModel.currentUser?.phoneNumber ?? "")
                            .font(.subheadline)
                            .foregroundColor(Color("TextColor"))
                    }
                    
                    HStack {
                        Text("Birth Date")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: 100, alignment: .leading)
                        
                        if let dob = userViewModel.currentUser?.dateOfBirth {
                            Text(dateFormatter.string(from: dob))
                                .font(.subheadline)
                                .foregroundColor(Color("TextColor"))
                        }
                    }
                    
                    Button(action: {
                        showingSettingsSheet = true
                    }) {
                        Text("Edit Profile")
                            .font(.subheadline)
                            .foregroundColor(Color("PrimaryBlue"))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color("PrimaryBlue").opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Health information
                VStack(alignment: .leading, spacing: 16) {
                    Text("Health Information")
                        .font(.headline)
                        .foregroundColor(Color("TextColor"))
                    
                    if let conditions = userViewModel.currentUser?.healthConditions, !conditions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Health Conditions")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            ForEach(conditions, id: \.self) { condition in
                                HStack {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 6))
                                        .foregroundColor(Color("PrimaryBlue"))
                                    
                                    Text(condition)
                                        .font(.subheadline)
                                        .foregroundColor(Color("TextColor"))
                                }
                            }
                        }
                    } else {
                        Text("No health conditions recorded")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                    
                    if let allergies = userViewModel.currentUser?.allergies, !allergies.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Allergies")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            ForEach(allergies, id: \.self) { allergy in
                                HStack {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 6))
                                        .foregroundColor(Color("PrimaryBlue"))
                                    
                                    Text(allergy)
                                        .font(.subheadline)
                                        .foregroundColor(Color("TextColor"))
                                }
                            }
                        }
                    } else {
                        Text("No allergies recorded")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        showingHealthDataSheet = true
                    }) {
                        Text("Update Health Information")
                            .font(.subheadline)
                            .foregroundColor(Color("PrimaryBlue"))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color("PrimaryBlue").opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Family members
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Family Members")
                            .font(.headline)
                            .foregroundColor(Color("TextColor"))
                        
                        Spacer()
                        
                        Button(action: {
                            selectedFamilyMember = nil
                            showingFamilyMemberSheet = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color("PrimaryBlue"))
                        }
                    }
                    
                    if let members = userViewModel.currentUser?.familyMembers, !members.isEmpty {
                        ForEach(members) { member in
                            FamilyMemberRow(member: member)
                                .onTapGesture {
                                    selectedFamilyMember = member
                                    showingFamilyMemberSheet = true
                                }
                        }
                    } else {
                        Text("No family members added")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.vertical, 8)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Logout button
                Button(action: {
                    userViewModel.logout()
                }) {
                    Text("Log Out")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red, lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
            }
            .padding()
        }
        .background(Color("BackgroundColor"))
        .navigationTitle("My Profile")
        .sheet(isPresented: $showingFamilyMemberSheet) {
            if let member = selectedFamilyMember {
                FamilyMemberView(familyMember: member, isEditing: true)
            } else {
                FamilyMemberView(isEditing: false)
            }
        }
        .sheet(isPresented: $showingHealthDataSheet) {
            HealthDataView()
        }
        .sheet(isPresented: $showingSettingsSheet) {
            Text("Settings View") // Placeholder for settings view
        }
    }
}

struct FamilyMemberRow: View {
    let member: FamilyMember
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        HStack {
            // Initial Circle
            ZStack {
                Circle()
                    .fill(relationshipColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Text(member.firstName.prefix(1).uppercased())
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(relationshipColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(member.firstName) \(member.lastName)")
                    .font(.headline)
                    .foregroundColor(Color("TextColor"))
                
                HStack {
                    Text(member.relationship)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 8)
                        .background(relationshipColor)
                        .cornerRadius(10)
                    
                    Text(dateFormatter.string(from: member.dateOfBirth))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white.opacity(0.5))
        .cornerRadius(8)
    }
    
    // Color based on relationship
    var relationshipColor: Color {
        switch member.relationship.lowercased() {
        case "child":
            return .blue
        case "parent":
            return .purple
        case "spouse", "partner":
            return .red
        case "sibling":
            return .green
        default:
            return .orange
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
                .environmentObject(UserViewModel())
        }
    }
}
