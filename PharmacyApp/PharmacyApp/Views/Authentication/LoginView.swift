//
//  LoginView.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var username: String = "demo"
    @State private var password: String = "password"
    @State private var rememberMe: Bool = false
    @State private var isSignUpActive: Bool = false
    @State private var showForgotPasswordAlert: Bool = false
    @State private var forgotPasswordEmail: String = ""
    @State private var showPasswordResetMessage: Bool = false
    @State private var passwordResetMessage: String = ""
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color("PrimaryBlue"), Color("SecondaryBlue")]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Logo and title
                VStack(spacing: 8) {
                    Image(systemName: "cross.case.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                    
                    Text("PharmaTrack")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Your health journey companion")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 40)
                
                // Login form
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Username")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        TextField("", text: $username)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        SecureField("", text: $password)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Toggle(isOn: $rememberMe) {
                            Text("Remember me")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color.white))
                        
                        Spacer()
                        
                        Button(action: {
                            showForgotPasswordAlert = true
                            forgotPasswordEmail = ""
                        }) {
                            Text("Forgot Password?")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                    }
                    
                    if let error = userViewModel.loginError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .padding(.top, 4)
                    }
                    
                    if userViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.top, 8)
                    } else {
                        Button(action: {
                            userViewModel.login(username: username, password: password)
                        }) {
                            Text("Login")
                                .font(.headline)
                                .foregroundColor(Color("PrimaryBlue"))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                        .padding(.top, 8)
                    }
                    
                    HStack {
                        Text("Don't have an account?")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            isSignUpActive = true
                        }) {
                            Text("Sign up")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                Text("For demo, use username: demo, password: password")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 20)
            }
            .padding(.vertical, 60)
        }
        .sheet(isPresented: $isSignUpActive) {
            SignUpView()
        }
        // Forgot Password Alert
        .alert("Reset Password", isPresented: $showForgotPasswordAlert) {
            TextField("Enter your email", text: $forgotPasswordEmail)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            Button("Cancel", role: .cancel) {}
            
            Button("Send Reset Link") {
                sendPasswordReset(email: forgotPasswordEmail)
            }
        } message: {
            Text("Enter the email associated with your account. We'll send you a link to reset your password.")
        }
        // Password Reset Confirmation Alert
        .alert(isPresented: $showPasswordResetMessage) {
            Alert(
                title: Text("Password Reset"),
                message: Text(passwordResetMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func sendPasswordReset(email: String) {
        guard !email.isEmpty else {
            passwordResetMessage = "Please enter your email address."
            showPasswordResetMessage = true
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                passwordResetMessage = "Error: \(error.localizedDescription)"
            } else {
                passwordResetMessage = "A password reset link has been sent to your email."
            }
            showPasswordResetMessage = true
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserViewModel())
    }
}
