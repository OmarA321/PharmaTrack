//
//  PrescriptionViewModel.swift
//  PharmacyApp
//
//  Created by Omar Al dulaimi on 2025-03-31.
//

import Foundation
import Combine
import FirebaseFirestore

class PrescriptionViewModel: ObservableObject {
    @Published var prescriptions: [Prescription] = []
    @Published var selectedPrescription: Prescription?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var prescriptionListener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    
    // Reference to our service
    private let prescriptionService = PrescriptionFirestoreService.shared
    
//    init() {
//        // For prototype/development purposes, we can still initialize with mock data
//        loadMockData()
//    }
    
    deinit {
        // Clean up listener when ViewModel is deallocated
        prescriptionListener?.remove()
    }
    
    // MARK: - Mock Data (for development/preview)
//    
//    private func loadMockData() {
//        self.prescriptions = MockDataService.shared.getMockPrescriptions()
//    }
    
    // MARK: - Firestore Data Operations
    
    func loadUserPrescriptions(userId: String) {
        isLoading = true
        errorMessage = nil
        
        // Remove previous listener if exists
        prescriptionListener?.remove()
        
        // Set up real-time listener for prescription updates
        prescriptionListener = prescriptionService.listenForPrescriptionChanges(userId: userId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let prescriptions):
                    self.prescriptions = prescriptions.sorted(by: { $0.prescribedDate > $1.prescribedDate })
                    self.errorMessage = nil
                    
                    // Update selected prescription if needed
                    if let selectedId = self.selectedPrescription?.id,
                       let updatedPrescription = prescriptions.first(where: { $0.id == selectedId }) {
                        self.selectedPrescription = updatedPrescription
                    }
                    
                case .failure(let error):
                    self.errorMessage = "Failed to load prescriptions: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func selectPrescription(_ prescription: Prescription) {
        self.selectedPrescription = prescription
    }
    
    func updatePrescriptionStatus(id: String, newStatus: PrescriptionStatus, message: String? = nil) {
        isLoading = true
        errorMessage = nil
        
        prescriptionService.updatePrescriptionStatus(id: id, newStatus: newStatus, message: message) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success:
                    // Real-time listener will update the prescriptions array
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = "Failed to update status: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func updateAdherence(prescriptionId: String, adherencePercentage: Double) {
        isLoading = true
        errorMessage = nil
        
        prescriptionService.updateAdherence(prescriptionId: prescriptionId, adherencePercentage: adherencePercentage) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success:
                    // Real-time listener will update the prescriptions array
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = "Failed to update adherence: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func addPharmacistMessage(prescriptionId: String, message: String) {
        isLoading = true
        errorMessage = nil
        
        prescriptionService.addPharmacistMessage(prescriptionId: prescriptionId, message: message) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success:
                    // Real-time listener will update the prescriptions array
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = "Failed to add message: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func addUserReply(prescriptionId: String, message: String) -> Bool {
        var success = false
        let semaphore = DispatchSemaphore(value: 0)
        
        isLoading = true
        errorMessage = nil
        
        prescriptionService.addUserReply(prescriptionId: prescriptionId, message: message) { [weak self] result in
            guard let self = self else {
                semaphore.signal()
                return
            }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let didSucceed):
                    success = didSucceed
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = "Failed to add reply: \(error.localizedDescription)"
                    success = false
                }
                
                semaphore.signal()
            }
        }
        
        _ = semaphore.wait(timeout: .now() + 5)
        return success
    }
    
    // Methods for handling prescription refills
    func requestRefill(for prescriptionId: String) {
        isLoading = true
        errorMessage = nil
        
        prescriptionService.requestRefill(for: prescriptionId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success:
                    // Real-time listener will update the prescriptions array
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = "Failed to request refill: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Method to confirm pickup of a prescription
    func confirmPickup(for prescriptionId: String) {
        isLoading = true
        errorMessage = nil
        
        prescriptionService.confirmPickup(for: prescriptionId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success:
                    // Real-time listener will update the prescriptions array
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = "Failed to confirm pickup: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Method to submit a new prescription request
    func submitPrescriptionRequest(prescription: Prescription) {
        isLoading = true
        errorMessage = nil
        
        prescriptionService.createPrescription(prescription) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let newPrescription):
                    // Add the new prescription to our array (the listener would do this too)
                    self.prescriptions.append(newPrescription)
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = "Failed to submit prescription: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // Existing helper methods
    
    // Method to get prescriptions for a specific family member
    func getPrescriptionsForFamilyMember(id: String) -> [Prescription] {
        return prescriptions.filter { $0.forUser == id }
    }
    
    // Method to get prescriptions by status
    func getPrescriptionsByStatus(status: PrescriptionStatus) -> [Prescription] {
        return prescriptions.filter { $0.status == status }
    }
    
    // Method to get active prescriptions (not completed)
    func getActivePrescriptions() -> [Prescription] {
        return prescriptions.filter { $0.status != .completed }
    }
    
    // Method to get prescriptions with pharmacist messages
    func getPrescriptionsWithPharmacistMessages() -> [Prescription] {
        return prescriptions.filter {
            ($0.pharmacistMessage != nil && !$0.pharmacistMessage!.isEmpty) ||
            ($0.pharmacistMessages != nil && !$0.pharmacistMessages!.isEmpty)
        }
    }
    
    // Method to check if a prescription has unread pharmacist messages
    func hasUnreadPharmacistMessages(_ prescriptionId: String) -> Bool {
        guard let prescription = prescriptions.first(where: { $0.id == prescriptionId }) else { return false }
        
        if let messages = prescription.pharmacistMessages {
            // Check if there are pharmacist messages without user replies
            let pharmacistMessages = messages.filter { !$0.isFromUser }
            let userMessages = messages.filter { $0.isFromUser }
            
            // If there are more pharmacist messages than user messages, there are unread messages
            return pharmacistMessages.count > userMessages.count
        }
        
        // Legacy check for old pharmacistMessage field
        return prescription.pharmacistMessage != nil && !prescription.pharmacistMessage!.isEmpty
    }
}
