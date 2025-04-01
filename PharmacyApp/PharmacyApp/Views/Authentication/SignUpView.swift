//
//  SignUpView.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var userViewModel: UserViewModel
    
    // User information
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var dateOfBirth = Date()
    @State private var userType: UserType = .patient
    
    // Health information for patients
    @State private var healthConditionsText: String = ""
    @State private var allergiesText: String = ""
    
    // Pharmacist information
    @State private var pharmacyName: String = ""
    @State private var licenseNumber: String = ""
    
    
    
    // UI control
    @State private var currentStep: Int = 1
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isRegistrationComplete: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                VStack {
                    // Progress indicator
                    HStack(spacing: 4) {
                        ForEach(1...3, id: \.self) { step in
                            Circle()
                                .frame(width: 12, height: 12)
                                .foregroundColor(step <= currentStep ? Color("PrimaryBlue") : Color.gray.opacity(0.3))
                            
                            if step < 3 {
                                Rectangle()
                                    .frame(width: 40, height: 2)
                                    .foregroundColor(step < currentStep ? Color("PrimaryBlue") : Color.gray.opacity(0.3))
                            }
                        }
                    }
                    .padding(.vertical, 20)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Step 1: Basic Info and User Type
                            if currentStep == 1 {
                                VStack(alignment: .leading, spacing: 20) {
                                    Text("Personal Information")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .padding(.bottom, 10)
                                    
                                    // User Type Selection
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("I am a:")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        Picker("User Type", selection: $userType) {
                                            Text("Patient").tag(UserType.patient)
                                            Text("Pharmacist").tag(UserType.pharmacist)
                                        }
                                        .pickerStyle(SegmentedPickerStyle())
                                        .padding(.vertical, 8)
                                    }
                                    
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
                                    
                                    // Email
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Email")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        TextField("Email", text: $email)
                                            .keyboardType(.emailAddress)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    }
                                    
                                    // Phone Number
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Phone Number")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        TextField("Phone Number", text: $phoneNumber)
                                            .keyboardType(.phonePad)
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
                                }
                            }
                            
                            // Step 2: Account Info
                            else if currentStep == 2 {
                                VStack(alignment: .leading, spacing: 20) {
                                    Text("Account Information")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .padding(.bottom, 10)
                                    
                                    // Username
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Username")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        TextField("Username", text: $username)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    }
                                    
                                    // Password
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Password")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        SecureField("Password", text: $password)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    }
                                    
                                    // Confirm Password
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Confirm Password")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        SecureField("Confirm Password", text: $confirmPassword)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    }
                                    
                                    Text("Password must be at least 8 characters and include a number and a special character.")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding(.top, 5)
                                }
                            }
                            
                            // Step 3: User Type-Specific Info
                            else if currentStep == 3 {
                                if userType == .patient {
                                    // Patient health information
                                    VStack(alignment: .leading, spacing: 20) {
                                        Text("Health Information")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .padding(.bottom, 10)
                                        
                                        // Health Conditions
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("Health Conditions (separate with commas)")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            
                                            TextEditor(text: $healthConditionsText)
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
                                            
                                            TextEditor(text: $allergiesText)
                                                .frame(height: 100)
                                                .padding()
                                                .background(Color.white)
                                                .cornerRadius(10)
                                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                        }
                                        
                                        Text("This information helps us provide better medication management and alerts.")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .padding(.top, 5)
                                    }
                                } else {
                                    // Pharmacist information
                                    VStack(alignment: .leading, spacing: 20) {
                                        Text("Pharmacist Information")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .padding(.bottom, 10)
                                        
                                        // Pharmacy Name
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("Pharmacy Name")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            
                                            TextField("Pharmacy Name", text: $pharmacyName)
                                                .padding()
                                                .background(Color.white)
                                                .cornerRadius(10)
                                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                        }
                                        
                                        // License Number
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("License Number")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            
                                            TextField("License Number", text: $licenseNumber)
                                                .padding()
                                                .background(Color.white)
                                                .cornerRadius(10)
                                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                        }
                                        
                                        Text("Your license number will be verified before account activation.")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .padding(.top, 5)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    // Navigation buttons
                    HStack {
                        if currentStep > 1 {
                            Button(action: {
                                withAnimation {
                                    currentStep -= 1
                                }
                            }) {
                                Text("Back")
                                    .fontWeight(.medium)
                                    .foregroundColor(Color("PrimaryBlue"))
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color("PrimaryBlue"), lineWidth: 1)
                                    )
                            }
                            .padding(.trailing, 8)
                        }
                        
                        if userViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Button(action: {
                                if currentStep < 3 {
                                    // Validate current step
                                    if validateCurrentStep() {
                                        withAnimation {
                                            currentStep += 1
                                        }
                                    }
                                } else {
                                    // Final submission
                                    completeSignUp()
                                }
                            }) {
                                Text(currentStep < 3 ? "Next" : "Create Account")
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color("PrimaryBlue"))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitle("Sign Up", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(Color("PrimaryBlue"))
            })
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(isRegistrationComplete ? "Success" : "Notice"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if isRegistrationComplete {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            }
        }
    }
    
    // Validation for each step
    private func validateCurrentStep() -> Bool {
        switch currentStep {
        case 1:
            if firstName.isEmpty || lastName.isEmpty || email.isEmpty || phoneNumber.isEmpty {
                alertMessage = "Please fill in all fields"
                showAlert = true
                return false
            }
            
            // Validate email format
            if !isValidEmail(email) {
                alertMessage = "Please enter a valid email address"
                showAlert = true
                return false
            }
            
            return true
            
        case 2:
            if username.isEmpty || password.isEmpty || confirmPassword.isEmpty {
                alertMessage = "Please fill in all fields"
                showAlert = true
                return false
            }
            
            if password != confirmPassword {
                alertMessage = "Passwords do not match"
                showAlert = true
                return false
            }
            
            if password.count < 8 {
                alertMessage = "Password must be at least 8 characters"
                showAlert = true
                return false
            }
            
            // Check if password contains a number and a special character
            let hasNumber = password.contains(where: { $0.isNumber })
            let hasSpecialChar = password.contains(where: { !$0.isLetter && !$0.isNumber })
            
            if !hasNumber || !hasSpecialChar {
                alertMessage = "Password must include at least one number and one special character"
                showAlert = true
                return false
            }
            
            return true
            
        case 3:
            if userType == .pharmacist {
                if pharmacyName.isEmpty || licenseNumber.isEmpty {
                    alertMessage = "Please fill in all fields"
                    showAlert = true
                    return false
                }
            }
            return true
            
        default:
            return true
        }
    }
    
    // Email validation helper
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Complete sign up process
    private func completeSignUp() {
        // Create a new user
        let healthConditions = healthConditionsText.isEmpty ? [] : healthConditionsText.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let allergies = allergiesText.isEmpty ? [] : allergiesText.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        var user = User(
            username: username,
            email: email,
            firstName: firstName,
            lastName: lastName,
            dateOfBirth: dateOfBirth,
            phoneNumber: phoneNumber,
            healthConditions: healthConditions,
            allergies: allergies,
            familyMembers: [],
            userType: userType
        )
        
        // Add type-specific information
        if userType == .pharmacist {
            user.pharmacyName = pharmacyName
            user.licenseNumber = licenseNumber
        }
        
        // Register user with Firebase
        userViewModel.signUp(userData: user, password: password) { success, errorMessage in
            if success {
                isRegistrationComplete = true
                alertMessage = "Account successfully created! You can now log in."
                showAlert = true
            } else {
                isRegistrationComplete = false
                alertMessage = errorMessage ?? "An error occurred during registration"
                showAlert = true
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(UserViewModel())
    }
}
