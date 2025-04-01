//
//  HealthDataView.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import SwiftUI

struct HealthDataView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var userViewModel: UserViewModel
    
    // Form fields
    @State private var healthConditions: String = ""
    @State private var allergies: String = ""
    @State private var showingConfirmation: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor").edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header image
                        ZStack {
                            Circle()
                                .fill(Color("PrimaryBlue").opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "heart.text.square.fill")
                                .font(.system(size: 44))
                                .foregroundColor(Color("PrimaryBlue"))
                        }
                        .padding(.top, 20)
                        
                        Text("Health Information")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("TextColor"))
                        
                        Text("This information helps us provide better medication management and alerts.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        // Form
                        VStack(spacing: 20) {
                            // Health Conditions
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Health Conditions (separate with commas)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                TextEditor(text: $healthConditions)
                                    .frame(height: 150)
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
                                    .frame(height: 150)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                        }
                        .padding()
                        
                        // Information block
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Why is this important?")
                                .font(.headline)
                                .foregroundColor(Color("TextColor"))
                            
                            HStack(alignment: .top) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .padding(.top, 2)
                                
                                Text("Health conditions and allergies help identify potential drug interactions and side effects.")
                                    .font(.subheadline)
                                    .foregroundColor(Color("TextColor"))
                            }
                            
                            HStack(alignment: .top) {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.blue)
                                    .padding(.top, 2)
                                
                                Text("You'll receive alerts when a prescription might affect your health condition or trigger an allergy.")
                                    .font(.subheadline)
                                    .foregroundColor(Color("TextColor"))
                            }
                            
                            HStack(alignment: .top) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.green)
                                    .padding(.top, 2)
                                
                                Text("Your health information is private and is only used to improve your prescription experience.")
                                    .font(.subheadline)
                                    .foregroundColor(Color("TextColor"))
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                        
                        // Save button
                        Button(action: {
                            saveHealthData()
                            showingConfirmation = true
                        }) {
                            Text("Save Health Information")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color("PrimaryBlue"))
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitle("Health Information", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .foregroundColor(Color("PrimaryBlue"))
                }
            )
            .onAppear {
                // Load existing health data
                if let user = userViewModel.currentUser {
                    healthConditions = user.healthConditions.joined(separator: ", ")
                    allergies = user.allergies.joined(separator: ", ")
                }
            }
            .alert(isPresented: $showingConfirmation) {
                Alert(
                    title: Text("Health Information Updated"),
                    message: Text("Your health information has been successfully updated."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
    
    // Save health data
    private func saveHealthData() {
        // Parse comma-separated health conditions and allergies
        let conditionsArray = healthConditions
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let allergiesArray = allergies
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        // Update user health data
        userViewModel.updateHealthData(
            healthConditions: conditionsArray,
            allergies: allergiesArray
        )
    }
}

struct HealthDataView_Previews: PreviewProvider {
    static var previews: some View {
        HealthDataView()
            .environmentObject(UserViewModel())
    }
}
