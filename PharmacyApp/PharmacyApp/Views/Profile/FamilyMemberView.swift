//
//  FamilyMemberView.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import SwiftUI

struct FamilyMemberView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var userViewModel: UserViewModel
    
    // For existing family member
    var familyMember: FamilyMember?
    var isEditing: Bool
    
    // Form fields
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var relationship: String = "Child"
    @State private var dateOfBirth = Date()
    @State private var healthConditions: String = ""
    @State private var allergies: String = ""
    
    // UI states
    @State private var showingDeleteAlert = false
    @State private var showingConfirmation = false
    
    // Available relationship types
    private let relationshipTypes = ["Child", "Parent", "Spouse", "Partner", "Sibling", "Other"]
    
    // Init for adding new member
    init(isEditing: Bool = false) {
        self.familyMember = nil
        self.isEditing = isEditing
    }
    
    // Init for editing existing member
    init(familyMember: FamilyMember, isEditing: Bool) {
        self.familyMember = familyMember
        self.isEditing = isEditing
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor").edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile image placeholder
                        ZStack {
                            Circle()
                                .fill(relationshipColor.opacity(0.2))
                                .frame(width: 100, height: 100)
                            
                            if !firstName.isEmpty {
                                Text(firstName.prefix(1).uppercased())
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(relationshipColor)
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(relationshipColor)
                            }
                        }
                        .padding(.top, 20)
                        
                        // Form fields
                        VStack(spacing: 20) {
                            // First Name
                            VStack(alignment: .leading, spacing: 5) {
                                Text("First Name")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                TextField("First Name", text: $firstName)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                            
                            // Last Name
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Last Name")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                TextField("Last Name", text: $lastName)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                            
                            // Relationship
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Relationship")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Picker("Relationship", selection: $relationship) {
                                    ForEach(relationshipTypes, id: \.self) { type in
                                        Text(type).tag(type)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                            
                            // Date of Birth
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Date of Birth")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                DatePicker("", selection: $dateOfBirth, in: ...Date(), displayedComponents: .date)
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .frame(maxHeight: 180)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                            
                            // Health Conditions
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Health Conditions (separate with commas)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                TextEditor(text: $healthConditions)
                                    .frame(height: 100)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                            
                            // Allergies
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Allergies (separate with commas)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                TextEditor(text: $allergies)
                                    .frame(height: 100)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                        }
                        .padding()
                        
                        // Actions
                        VStack(spacing: 16) {
                            Button(action: {
                                saveFamilyMember()
                                showingConfirmation = true
                            }) {
                                Text(familyMember == nil ? "Add Family Member" : "Update Family Member")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color("PrimaryBlue"))
                                    .cornerRadius(10)
                            }
                            
                            if familyMember != nil {
                                Button(action: {
                                    showingDeleteAlert = true
                                }) {
                                    Text("Remove Family Member")
                                        .font(.headline)
                                        .foregroundColor(.red)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.red, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitle(familyMember == nil ? "Add Family Member" : "Edit Family Member", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .foregroundColor(Color("PrimaryBlue"))
                }
            )
            .onAppear {
                // Populate with existing data if editing
                if let member = familyMember {
                    firstName = member.firstName
                    lastName = member.lastName
                    relationship = member.relationship
                    dateOfBirth = member.dateOfBirth
                    healthConditions = member.healthConditions.joined(separator: ", ")
                    allergies = member.allergies.joined(separator: ", ")
                }
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Remove Family Member"),
                    message: Text("Are you sure you want to remove this family member? This action cannot be undone."),
                    primaryButton: .destructive(Text("Remove")) {
                        removeFamilyMember()
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert(isPresented: $showingConfirmation) {
                Alert(
                    title: Text(familyMember == nil ? "Family Member Added" : "Family Member Updated"),
                    message: Text(familyMember == nil ? "The family member has been successfully added." : "The family member information has been updated."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
    
    // Helper computed property to get color based on relationship
    private var relationshipColor: Color {
        switch relationship.lowercased() {
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
    
    // Save family member
    private func saveFamilyMember() {
        // Parse comma-separated health conditions and allergies
        let conditionsArray = healthConditions
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let allergiesArray = allergies
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        if let existingMember = familyMember {
            // Update existing member
            var updatedMember = existingMember
            updatedMember.firstName = firstName
            updatedMember.lastName = lastName
            updatedMember.relationship = relationship
            updatedMember.dateOfBirth = dateOfBirth
            updatedMember.healthConditions = conditionsArray
            updatedMember.allergies = allergiesArray
            
            userViewModel.updateFamilyMemberHealthData(
                id: existingMember.id,
                healthConditions: conditionsArray,
                allergies: allergiesArray
            )
        } else {
            // Create new family member
            let newMember = FamilyMember(
                relationship: relationship,
                firstName: firstName,
                lastName: lastName,
                dateOfBirth: dateOfBirth,
                healthConditions: conditionsArray,
                allergies: allergiesArray
            )
            
            userViewModel.addFamilyMember(newMember)
        }
    }
    
    // Remove family member
    private func removeFamilyMember() {
        if let member = familyMember,
           let index = userViewModel.familyMembers.firstIndex(where: { $0.id == member.id }) {
            userViewModel.removeFamilyMember(at: index)
        }
    }
}

struct FamilyMemberView_Previews: PreviewProvider {
    static var previews: some View {
        FamilyMemberView(isEditing: false)
            .environmentObject(UserViewModel())
    }
}
