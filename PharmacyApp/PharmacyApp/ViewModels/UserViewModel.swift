//
//  UserViewModel.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-02.
//

import Foundation
import Combine
import Firebase
import FirebaseFirestore
import FirebaseAuth

class UserViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    @Published var loginError: String?
    @Published var familyMembers: [FamilyMember] = []
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let db = Firestore.firestore()
    
    init() {
        // Check if user is already logged in with Firebase
        Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let user = user {
                    self.isLoggedIn = true
                    self.fetchUserData(userId: user.uid)
                } else {
                    // For development mode, you can uncomment this to use mock data
                    // self.loadMockData()
                    self.isLoggedIn = false
                    self.currentUser = nil
                }
            }
        }
    }
    
    private func loadMockData() {
        // This would fetch from a server in a real app
        self.currentUser = User.example
        self.familyMembers = currentUser?.familyMembers ?? []
    }
    
    func login(username: String, password: String) {
        isLoading = true
        loginError = nil
        
        // First get the email associated with this username
        db.collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.loginError = "Error: \(error.localizedDescription)"
                        self.isLoading = false
                    }
                    return
                }
                
                guard let document = snapshot?.documents.first, let email = document.data()["email"] as? String else {
                    // Fall back to mock login for demo purposes
                    if username.lowercased() == "demo" && password == "password" {
                        self.loadMockData()
                        self.isLoggedIn = true
                        self.loginError = nil
                    } else {
                        self.loginError = "Username not found"
                    }
                    self.isLoading = false
                    return
                }
                
                // Now login with email and password
                Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
                    guard let self = self else { return }
                    
                    DispatchQueue.main.async {
                        if let error = error {
                            self.loginError = "Login failed: \(error.localizedDescription)"
                        } else {
                            self.loginError = nil
                            self.isLoggedIn = true
                            if let userId = result?.user.uid {
                                self.fetchUserData(userId: userId)
                            }
                        }
                        self.isLoading = false
                    }
                }
            }
    }
    
    func signUp(userData: User, password: String, completion: @escaping (Bool, String?) -> Void) {
        isLoading = true
        
        // Check if username already exists
        db.collection("users")
            .whereField("username", isEqualTo: userData.username)
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    self.isLoading = false
                    completion(false, "Error checking username: \(error.localizedDescription)")
                    return
                }
                
                if let snapshot = snapshot, !snapshot.documents.isEmpty {
                    self.isLoading = false
                    completion(false, "Username already exists")
                    return
                }
                
                // Create authentication account
                Auth.auth().createUser(withEmail: userData.email, password: password) { [weak self] (result, error) in
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.isLoading = false
                        completion(false, "Registration failed: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let userId = result?.user.uid else {
                        self.isLoading = false
                        completion(false, "Failed to get user ID")
                        return
                    }
                    
                    // Add user to the appropriate collection based on type
                    var user = userData
                    user.id = userId
                    
                    let collectionName = user.userType == .pharmacist ? "pharmacists" : "patients"
                    
                    do {
                        // Add to type-specific collection
                        try self.db.collection(collectionName).document(userId).setData(from: user)
                        
                        // Also add basic user data to general users collection for lookup
                        let basicUserData: [String: Any] = [
                            "email": user.email,
                            "username": user.username,
                            "userType": user.userType.rawValue,
                            "firstName": user.firstName,
                            "lastName": user.lastName
                        ]
                        
                        self.db.collection("users").document(userId).setData(basicUserData) { error in
                            self.isLoading = false
                            if let error = error {
                                completion(false, "Error saving user data: \(error.localizedDescription)")
                            } else {
                                self.currentUser = user
                                self.familyMembers = user.familyMembers
                                self.isLoggedIn = true
                                completion(true, nil)
                            }
                        }
                    } catch {
                        self.isLoading = false
                        completion(false, "Error saving user data: \(error.localizedDescription)")
                    }
                }
            }
    }
    
    func fetchUserData(userId: String) {
        isLoading = true
        
        // First check which type of user this is
        db.collection("users").document(userId).getDocument { [weak self] (snapshot, error) in
            guard let self = self, let data = snapshot?.data(), let userTypeString = data["userType"] as? String else {
                self?.isLoading = false
                return
            }
            
            let collectionName = userTypeString == UserType.pharmacist.rawValue ? "pharmacists" : "patients"
            
            // Now get the full user data from the appropriate collection
            self.db.collection(collectionName).document(userId).getDocument { (document, error) in
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let document = document, document.exists, let user = try? document.data(as: User.self) {
                        self.currentUser = user
                        self.familyMembers = user.familyMembers
                    } else {
                        print("Error fetching user data: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isLoggedIn = false
                self.currentUser = nil
                self.familyMembers = []
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func addFamilyMember(_ member: FamilyMember) {
        guard var user = currentUser, let userId = user.id else { return }
        
        user.familyMembers.append(member)
        self.currentUser = user
        self.familyMembers = user.familyMembers
        
        // Update in Firebase
        let collectionName = user.userType == .pharmacist ? "pharmacists" : "patients"
        
        do {
            try db.collection(collectionName).document(userId).setData(from: user)
        } catch {
            print("Error updating family member: \(error.localizedDescription)")
        }
    }
    
    func removeFamilyMember(at index: Int) {
        guard var user = currentUser, let userId = user.id else { return }
        
        user.familyMembers.remove(at: index)
        self.currentUser = user
        self.familyMembers = user.familyMembers
        
        // Update in Firebase
        let collectionName = user.userType == .pharmacist ? "pharmacists" : "patients"
        
        do {
            try db.collection(collectionName).document(userId).setData(from: user)
        } catch {
            print("Error removing family member: \(error.localizedDescription)")
        }
    }
    
    func updateHealthData(healthConditions: [String], allergies: [String]) {
        guard var user = currentUser, let userId = user.id else { return }
        
        user.healthConditions = healthConditions
        user.allergies = allergies
        self.currentUser = user
        
        // Update in Firebase
        let collectionName = user.userType == .pharmacist ? "pharmacists" : "patients"
        
        do {
            try db.collection(collectionName).document(userId).setData(from: user)
        } catch {
            print("Error updating health data: \(error.localizedDescription)")
        }
    }
    
    func updateFamilyMemberHealthData(id: String, healthConditions: [String], allergies: [String]) {
        guard var user = currentUser, let userId = user.id else { return }
        
        if let index = user.familyMembers.firstIndex(where: { $0.id == id }) {
            user.familyMembers[index].healthConditions = healthConditions
            user.familyMembers[index].allergies = allergies
            self.currentUser = user
            self.familyMembers = user.familyMembers
            
            // Update in Firebase
            let collectionName = user.userType == .pharmacist ? "pharmacists" : "patients"
            
            do {
                try db.collection(collectionName).document(userId).setData(from: user)
            } catch {
                print("Error updating family member health data: \(error.localizedDescription)")
            }
        }
    }
    
    // For gamification
    func updateAdherenceScore(newScore: Int) {
        guard var user = currentUser, let userId = user.id else { return }
        
        user.adherenceScore = newScore
        self.currentUser = user
        
        // Update in Firebase
        let collectionName = user.userType == .pharmacist ? "pharmacists" : "patients"
        
        do {
            try db.collection(collectionName).document(userId).updateData(["adherenceScore": newScore])
        } catch {
            print("Error updating adherence score: \(error.localizedDescription)")
        }
    }
    
    func addBadge(_ badge: Badge) {
        guard var user = currentUser, let userId = user.id else { return }
        
        user.badges.append(badge)
        self.currentUser = user
        
        // Update in Firebase
        let collectionName = user.userType == .pharmacist ? "pharmacists" : "patients"
        
        do {
            try db.collection(collectionName).document(userId).setData(from: user)
        } catch {
            print("Error adding badge: \(error.localizedDescription)")
        }
    }
    
    func markHealthInfoAsRead(_ healthInfoId: String) {
        guard var user = currentUser, let userId = user.id else { return }
        
        user.healthInfoRead.append(healthInfoId)
        self.currentUser = user
        
        // Update in Firebase
        let collectionName = user.userType == .pharmacist ? "pharmacists" : "patients"
        
        do {
            try db.collection(collectionName).document(userId).updateData([
                "healthInfoRead": FieldValue.arrayUnion([healthInfoId])
            ])
        } catch {
            print("Error marking health info as read: \(error.localizedDescription)")
        }
    }
    
    func incrementMinigamesPlayed() {
        guard var user = currentUser, let userId = user.id else { return }
        
        user.minigamesPlayed += 1
        self.currentUser = user
        
        // Update in Firebase
        let collectionName = user.userType == .pharmacist ? "pharmacists" : "patients"
        
        do {
            try db.collection(collectionName).document(userId).updateData([
                "minigamesPlayed": FieldValue.increment(Int64(1))
            ])
        } catch {
            print("Error incrementing minigames played: \(error.localizedDescription)")
        }
    }
}
